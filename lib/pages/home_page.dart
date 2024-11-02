import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_gemini/flutter_gemini.dart'; // Gemini Chatbot
import 'package:classifier/plant_library.dart'; // Disease class
import 'package:logging/logging.dart'; // Logging
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:uuid/uuid.dart'; // Unique IDs
import 'package:flutter_markdown/flutter_markdown.dart'; // For Markdown support

final Logger _logger = Logger('HomePage'); // Initialize logger

class HomePage extends StatefulWidget {
  final Disease? disease; // Can be null if accessed from menu
  final String? userImagePath; // Can be null if accessed from menu
  final bool shouldSendPrompt; // Control initial prompt

  const HomePage({
    super.key,
    this.disease,
    this.userImagePath,
    required this.shouldSendPrompt,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final Gemini gemini = Gemini.instance; // Chatbot instance

  List<types.Message> messages = []; // Chat messages
  List<Content> conversation = []; // Conversation history

  // Chat user objects
  final types.User currentUser = const types.User(id: '0', firstName: 'User');
  final types.User geminiUser = const types.User(
    id: '1',
    firstName: '✨ Gemini',
    imageUrl:
        'https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/google-gemini-icon.png',
  );

  // For picking images
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = []; // List to hold selected images

  final TextEditingController _textController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Send the disease prompt only if accessed via the "Chat More with AI" button
    if (widget.shouldSendPrompt && widget.disease != null) {
      _sendCombinedDiseaseDetails();
    }
  }

  // Function to merge disease details and image and send as one message
  void _sendCombinedDiseaseDetails() {
    String diseaseDetails = '''
**Disease**: ${widget.disease?.name}  
**Description**: ${widget.disease?.description}  
**Treatments**: ${widget.disease?.treatments.join(", ")}  
**Preventive Measures**: ${widget.disease?.preventiveMeasures.join(", ")}

Provide more insights about the disease and the image I sent you.''';

    // Create a custom message with text and image
    final message = types.CustomMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      metadata: {
        'text': diseaseDetails,
        'imageUris':
            widget.userImagePath != null ? [widget.userImagePath!] : [],
      },
    );

    _sendMessage(message); // Send the message
  }

  // Function to send a message
  void _sendMessage(types.Message message) {
    setState(() {
      messages.insert(0, message); // Add user's message to the list
    });

    try {
      String question = '';
      List<Uint8List>? images;

      if (message is types.ImageMessage) {
        // If the message is an image message
        question = '';
        images = [File(message.uri).readAsBytesSync()];
      } else if (message is types.TextMessage) {
        question = message.text;
      } else if (message is types.CustomMessage) {
        // If the message is a custom message with text and images
        if (message.metadata != null) {
          question = message.metadata!['text'] ?? '';
          if (message.metadata!['imageUris'] != null) {
            images = (message.metadata!['imageUris'] as List<dynamic>)
                .map((uri) => File(uri as String).readAsBytesSync())
                .toList();
          }
        }
      }

      // Add user's message to the conversation history
      conversation.add(
        Content(
          parts: [Parts(text: question)],
          role: 'user',
        ),
      );

      // Create a placeholder for the AI response with typing indicator
      final aiMessage = types.TextMessage(
        author: geminiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'Gemini is typing...',
      );

      setState(() {
        messages.insert(0, aiMessage); // Add the placeholder to the list
      });

      // Determine which Gemini API to call based on whether images are present
      if (images != null && images.isNotEmpty) {
        // Use textAndImage API
        gemini
            .textAndImage(
          text: question,
          images: images,
        )
            .then((value) {
          String content =
              value?.content?.parts?.map((part) => part.text).join('') ?? '';

          // Add the AI response to the conversation history
          conversation.add(
            Content(
              parts: [Parts(text: content)],
              role: 'model',
            ),
          );

          setState(() {
            // Update the AI message in the list
            if (messages.isNotEmpty &&
                messages[0].author.id == geminiUser.id &&
                messages[0] is types.TextMessage &&
                (messages[0] as types.TextMessage).text ==
                    'Gemini is typing...') {
              messages[0] = types.TextMessage(
                author: geminiUser,
                createdAt: messages[0].createdAt,
                id: messages[0].id,
                text: content,
              );
            }
          });
        }).catchError((e) {
          _logger.severe('Failed to get AI response: $e');
        });
      } else {
        // Use chat API for multi-turn conversation
        gemini.chat(conversation).then((value) {
          String content = value?.output ?? '';

          // Add the AI response to the conversation history
          conversation.add(
            Content(
              parts: [Parts(text: content)],
              role: 'model',
            ),
          );

          setState(() {
            // Update the AI message in the list
            if (messages.isNotEmpty &&
                messages[0].author.id == geminiUser.id &&
                messages[0] is types.TextMessage &&
                (messages[0] as types.TextMessage).text ==
                    'Gemini is typing...') {
              messages[0] = types.TextMessage(
                author: geminiUser,
                createdAt: messages[0].createdAt,
                id: messages[0].id,
                text: content,
              );
            }
          });
        }).catchError((e) {
          _logger.severe('Failed to get AI response: $e');
        });
      }
    } catch (e) {
      _logger.severe('Failed to send message: $e');
    }
  }

  // Function to handle sending of combined text and images
  void _handleSendPressed(types.PartialText partialText) {
    if (partialText.text.trim().isEmpty && _selectedImages.isEmpty) {
      // Do not send empty messages
      return;
    }

    // Create a custom message with text and images
    final message = types.CustomMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      metadata: {
        'text':
            partialText.text.trim().isNotEmpty ? partialText.text.trim() : '',
        'imageUris': _selectedImages.map((file) => file.path).toList(),
      },
    );

    _sendMessage(message);

    // Clear selected images after sending
    setState(() {
      _selectedImages.clear();
      _textController.clear();
    });
  }

  // Function to pick an image and add it to the selected images
  Future<void> _handleImageSelection() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  // Function to clear the chat
  void _clearChat() {
    setState(() {
      messages.clear();
      conversation.clear();
      _selectedImages.clear();
    });
  }

  // Custom message builder to handle messages with markdown and images
  Widget _messageBuilder(types.Message message, {required int messageWidth}) {
    // Determine if the message is from the user or AI
    bool isUser = message.author.id == currentUser.id;

    if (message is types.TextMessage) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.green[200] : Colors.green[100],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16.0),
              strong: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    } else if (message is types.ImageMessage) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
            child: Image.file(
              File(message.uri),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (message is types.CustomMessage) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.green[200] : Colors.green[100],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.metadata != null &&
                  message.metadata!['text'] != null &&
                  (message.metadata!['text'] as String).isNotEmpty)
                MarkdownBody(
                  data: message.metadata!['text'] as String,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16.0),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (message.metadata != null &&
                  message.metadata!['imageUris'] != null &&
                  (message.metadata!['imageUris'] as List).isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (message.metadata!['imageUris'] as List).length,
                    itemBuilder: (context, index) {
                      String uri =
                          message.metadata!['imageUris'][index] as String;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(16.0), // Rounded corners
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              child: Image.file(
                                File(uri),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () {
                                // Optionally implement removing images from messages
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Colors.green),
                onPressed: _handleImageSelection,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {
                  final text = _textController.text;
                  _handleSendPressed(types.PartialText(text: text));
                },
              ),
            ],
          ),
        ),
        // Display selected images below the input bar
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16.0), // Rounded corners
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white, // Set Scaffold background to white
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white, // White background for rounded title
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          child: const Text(
            "✨ Gemini Chat",
            style: TextStyle(
              color: Colors.green, // Green text color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF66BB6A)], // Green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Chat(
        messages: messages,
        onSendPressed: _handleSendPressed,
        user: currentUser,
        theme: DefaultChatTheme(
          primaryColor: Colors.green,
          inputBackgroundColor: Colors.white,
          sendButtonIcon: const Icon(Icons.send, color: Colors.green),
          inputTextColor: Colors.black,
          inputBorderRadius: BorderRadius.circular(20.0),
        ),
        customMessageBuilder: _messageBuilder,
        showUserAvatars: false,
        showUserNames: false,
        customBottomWidget: _buildInput(),
      ),
    );
  }
}

extension on types.CustomMessage {
  String? get text => metadata?['text'] as String?;
  List<String>? get imageUris => metadata?['imageUris'] != null
      ? List<String>.from(metadata!['imageUris'] as List<dynamic>)
      : null;
}
