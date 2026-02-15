import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Message> _messages = [];

  bool _isTyping = false;
  bool _hasText = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    _loadChatHistory();

    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  /// ================= LOAD HISTORY =================
  Future<void> _loadChatHistory() async {
    try {
      final history = await ChatService.fetchChatHistory();

      setState(() {
        _messages.clear();
        for (var msg in history) {
          _messages.add(
            Message(
              text: msg['message'],
              isUser: msg['role'] == 'user',
              timestamp: DateTime.parse(msg['created_at']),
            ),
          );
        }
      });

      _scrollToBottom();
    } catch (_) {}
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// ================= SEND TEXT =================
  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;

    setState(() {
      _messages.add(Message(text: userText, isUser: true));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final botReply = await ChatService.sendMessage(userText);

      setState(() {
        _isTyping = false;
        _messages.add(Message(text: botReply, isUser: false));
      });

      _scrollToBottom();
    } catch (_) {
      setState(() {
        _isTyping = false;
        _messages.add(
          Message(
            text: "I'm having trouble connecting right now.",
            isUser: false,
          ),
        );
      });
    }
  }

  /// ================= SPEECH =================
  Future<void> _toggleListening() async {
    if (!_isListening) {
      /// 🔥 Request permission FIRST
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied")),
        );
        return;
      }

      /// Initialize speech engine
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == "done") {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MindEaseAI Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// CHAT AREA
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("MindEaseAI is typing..."),
                  );
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          /// INPUT FIELD
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? "Listening..."
                          : "Type your message...",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// SEND OR MIC BUTTON
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? CircleAvatar(
                          key: const ValueKey("send"),
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: sendMessage,
                          ),
                        )
                      : CircleAvatar(
                          key: const ValueKey("mic"),
                          backgroundColor:
                              _isListening ? Colors.red : Colors.green,
                          child: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                            ),
                            onPressed: _toggleListening,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
