import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// The entry point of the app
void main() {
  runApp(const ChatApp());
}

// Main widget for the chat application
class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => ChatAppState();
}

// State class for the chat app
class ChatAppState extends State<ChatApp> {
  bool _isAPIReady = false; // Flag to check if the Gemini API is ready to use
  bool _isGenerating =
      false; // Flag to indicate if the app is generating a response
  late GeminiService _geminiService; // Service to interact with Gemini API
  final TextEditingController _messageController =
      TextEditingController(); // Controller for the input text
  final ScrollController _scrollController =
      ScrollController(); // Controller for scrolling the chat view
  final List<ChatMessage> _messages = []; // List to store chat messages

  // Initial setup when the app starts
  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Hello! Please enter your Gemini API key."); // Initial bot message asking for API key
  }

  // Adds a message from the user to the chat
  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
    _scrollToBottom(); // Scroll to the latest message
  }

  // Adds a message from the bot to the chat
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
      ));
    });
    _scrollToBottom(); // Scroll to the latest message
  }

  // Scroll to the bottom of the chat view
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Handles the submission of a message (either by user or bot)
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return; // Do nothing if the input is empty

    _messageController.clear(); // Clear the input field

    // If the API is ready, send the message to the bot
    if (_isAPIReady) {
      _addUserMessage(text); // Add user message to the chat

      setState(() {
        _isGenerating = true; // Show that the app is generating a response
      });

      try {
        // Call the Gemini API to generate a response
        final response = await _geminiService.generateText(text);
        _addBotMessage(response); // Add the bot's response to the chat
      } catch (e) {
        _addBotMessage("Sorry, there's an error. ${e.toString()}");
        _isAPIReady = false; // Disable the API if there's an error
      } finally {
        setState(() {
          _isGenerating = false; // Hide the loading state
        });
      }
    } else {
      // If the API is not ready, set it up with the provided API key
      setState(() {
        _geminiService =
            GeminiService(text); // Set the API service with the provided key
        _addUserMessage("******"); // Add a placeholder message for the key
        _addBotMessage(
            "API key received."); // Notify the user that the key was received
        _isAPIReady = true; // API is now ready to use
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double shortest = MediaQuery.of(context)
        .size
        .shortestSide; // Get the smallest screen dimension
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectionArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // The chat messages list view
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: SizedBox(
                            width: shortest,
                            // Make sure messages fit the screen width
                            child: _messages[index],
                          ),
                        );
                      },
                    ),
                  ),
                  // Text input area for the user to type messages
                  Container(
                    width: shortest,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.black38),
                                hintText: _isAPIReady
                                    ? 'Ask anything' // Prompt for the user to ask questions
                                    : "Enter Your API Key",
                                // Prompt to enter API key
                                border: InputBorder.none,
                              ),
                              minLines: 1,
                              maxLines: 8,
                              onSubmitted:
                                  _handleSubmitted, // Handle submission of text input
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black),
                                    child: _isGenerating
                                        ? Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Icon(
                                              Icons.square_rounded,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                  ),
                                  onTap: () => _handleSubmitted(
                                      _messageController
                                          .text), // Handle tap on send button
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget to display individual chat messages
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    double shortest = MediaQuery.of(context)
        .size
        .shortestSide; // Get the smallest screen dimension
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          if (isUser) Expanded(child: SizedBox()),
          // Align user messages to the right
          Container(
            constraints: BoxConstraints(
                maxWidth: isUser ? shortest * 0.7 : shortest - 32),
            // Adjust message width
            decoration: isUser
                ? BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            margin: const EdgeInsets.only(top: 5.0),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Text(
                text,
                style: TextStyle(fontSize: 16), // Message text style
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Service to interact with the Gemini API
class GeminiService {
  GeminiService(this.apiKey);

  late String apiKey; // 🔑 Gemini API KEY
  final String modelId = "gemini-2.0-flash"; // Gemini Model

  // Function to generate text from the Gemini API
  Future<String> generateText(String inputText) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/$modelId:generateContent?key=$apiKey");

    final response = await http.post(
      url,
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": inputText}
            ]
          }
        ],
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": 1024}
      }),
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final candidates = result['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          return parts[0]['text']; // Return the generated text
        }
      }
      return "No text generated"; // Return a fallback message if no text is generated
    } else {
      throw Exception('Failed to generate text: ${response.body}');
    }
  }
}
