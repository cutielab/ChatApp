import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: '',
  );
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addMessage({required String text, required bool isUser}) async {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    await Future.delayed(Duration(milliseconds: 100));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendAndReceiveMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;
    _messageController.clear();
    _addMessage(text: text, isUser: true);
    setState(() {
      _isGenerating = true;
    });

    try {
      final response = await model.generateContent([Content.text(text)]);
      _addMessage(text: response.text ?? "No response", isUser: false);
    } catch (e) {
      _addMessage(text: "$e", isUser: false);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double shortest = MediaQuery.of(context).size.shortestSide;
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
                  Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: SizedBox(
                              width: shortest,
                              child: _messages[index],
                            ),
                          );
                        }),
                  ),
                  _buildInputField(shortest),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(double shortest) {
    return Container(
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
                        _sendAndReceiveMessage(_messageController.text);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    double shortest = MediaQuery.of(context).size.shortestSide;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: isUser
                ? BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            constraints: BoxConstraints(
                maxWidth: isUser ? shortest * 0.7 : shortest - 32),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
