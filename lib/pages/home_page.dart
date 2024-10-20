import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Assuming this handles the Gemini Chatbot
import 'package:classifier/plant_library.dart'; // Assuming the Disease class is defined here

class HomePage extends StatefulWidget {
  final Disease disease;
  final String? userImagePath;

  const HomePage({
    super.key,
    required this.disease,
    this.userImagePath,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance; // Chatbot instance

  List<ChatMessage> messages = []; // List of chat messages

  // Chat user objects
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    _sendCombinedDiseaseDetails(); // Automatically send the combined details when the page loads
  }

  // Function to merge disease details and image and send as one message
  void _sendCombinedDiseaseDetails() {
    String diseaseDetails = '''
Disease: ${widget.disease.name}
Description: ${widget.disease.description}
Treatments: ${widget.disease.treatments.join(", ")}
Preventive Measures: ${widget.disease.preventiveMeasures.join(", ")}
''';

    // If the image path is available, include it in the message
    if (widget.userImagePath != null) {
      diseaseDetails +=
          '\nHere is the captured image for the disease: ${widget.userImagePath!}';
    }

    // Adding the saying at the end of the prompt
    diseaseDetails +=
        '\n\nProvide more insights about the disease and the Image I sent you.';

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
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      // Send the message to Gemini AI
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        // Create a response message from AI
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini Chat"),
      ),
      body: DashChat(
        currentUser: currentUser,
        onSend: _sendMessage, // Message sending function
        messages: messages, // List of chat messages
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              onPressed: () {}, // You can add functionality here if needed
              icon: Icon(Icons.image),
            ),
          ],
        ),
      ),
    );
  }
}
