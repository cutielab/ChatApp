// Source code of "Build ChatGPT App with Flutter!! 1/3"

import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool _isGenerating = false;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendAndReceiveMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;
    _messageController.clear();
    setState(() {
      _isGenerating = true;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double shortest = MediaQuery.of(context).size.shortestSide;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: shortest,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black38),
                              hintText: 'Ask anything',
                              border: InputBorder.none,
                            ),
                            minLines: 1,
                            maxLines: 8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                    ),
                                    child: Padding(
                                      padding: _isGenerating
                                          ? const EdgeInsets.all(12.0)
                                          : const EdgeInsets.all(6.0),
                                      child: Icon(
                                        _isGenerating
                                            ? Icons.square_rounded
                                            : Icons.arrow_upward_rounded,
                                        color: Colors.white,
                                        size: _isGenerating ? 12 : 24,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _sendAndReceiveMessage(
                                        _messageController.text);
                                  }),
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
    );
  }
}

