import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Assuming this handles the Gemini Chatbot
import 'package:classifier/plant_library.dart'; // Assuming the Disease class is defined here
import 'package:logging/logging.dart'; // Added for logging
import 'package:image_picker/image_picker.dart'; // For picking images

final Logger _logger = Logger('HomePage'); // Initialize logger

class HomePage extends StatefulWidget {
  final Disease? disease; // Can be null if accessed from menu
  final String? userImagePath; // Can be null if accessed from menu
  final bool shouldSendPrompt; // New flag to control the initial prompt

  const HomePage({
    super.key,
    this.disease,
    this.userImagePath,
    required this.shouldSendPrompt,
  });

  @override
  HomePageState createState() => HomePageState(); // Changed to public
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final Gemini gemini = Gemini.instance; // Chatbot instance

  List<ChatMessage> messages = []; // List of chat messages

  // List to hold selected images before sending
  final List<XFile> selectedImages = [];

  // Chat user objects
  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "✨ Gemini",
    profileImage:
        "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/google-gemini-icon.png",
  );

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

    // If the image path is available, include it in the message
    if (widget.userImagePath != null) {
      diseaseDetails += ' Here is the captured image for the disease:';
    }

    // Send the combined disease details, image path, and prompt as one message
    ChatMessage combinedMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: diseaseDetails,
      medias: widget.userImagePath != null
          ? [
              ChatMedia(
                url: widget.userImagePath!,
                fileName: "Disease Image",
                type: MediaType.image,
              )
            ]
          : null, // Include the image if available
    );

    _sendMessage(combinedMessage); // Send the message
  }

  // Function to send a message
  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages]; // Add the message to the list
    });

    try {
      String question = chatMessage.text; // Message text
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = chatMessage.medias!
            .map((media) => File(media.url).readAsBytesSync())
            .toList();
      }

      // Send the message to Gemini AI
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        String response = event.content?.parts
                ?.fold("", (previous, current) => "$previous${current.text}") ??
            "";

        // Stripping multiple spaces and newlines for more continuous text
        response = response.replaceAll(RegExp(r'\s+'), ' ');

        // Create a response message from AI without breaking
        ChatMessage replyMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages = [replyMessage, ...messages];
        });
      });
    } catch (e) {
      _logger
          .severe('Failed to send message: $e'); // Use logger instead of print
    }
  }

  // Function to pick multiple images and add them to the selectedImages list
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // Function to send the combined message with text and selected images
  void _sendCombinedMessage(ChatMessage message) {
    String text = message.text;
    if (text.trim().isEmpty && selectedImages.isEmpty) {
      // Do not send empty messages
      return;
    }

    // Create a list of ChatMedia from selected images
    List<ChatMedia> medias = selectedImages.map((xfile) {
      return ChatMedia(
        url: xfile.path,
        fileName: "User Image",
        type: MediaType.image,
      );
    }).toList();

    // Include the medias from the message if any
    if (message.medias != null && message.medias!.isNotEmpty) {
      medias.addAll(message.medias!);
    }

    ChatMessage combinedMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text,
      medias: medias.isNotEmpty ? medias : null,
    );

    _sendMessage(combinedMessage);

    // Clear selected images after sending
    setState(() {
      selectedImages.clear();
    });
  }

  // Function to clear the chat
  void _clearChat() {
    setState(() {
      messages.clear();
      selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: currentUser,
              onSend: (ChatMessage message) {
                // Use the custom send function to handle combined messages
                _sendCombinedMessage(message);
              },
              messages: messages,
              inputOptions: InputOptions(
                alwaysShowSend: true,
                sendButtonBuilder: (sendPressed) {
                  return IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: sendPressed,
                  );
                },
                trailing: [
                  IconButton(
                    onPressed: _pickImages, // Pick multiple images
                    icon: const Icon(Icons.image, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          // Display selected images with remove (X) buttons
          if (selectedImages.isNotEmpty)
            Container(
              height: 100,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(
                            File(selectedImages[index].path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
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
    );
  }
}
