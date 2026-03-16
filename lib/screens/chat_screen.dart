import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Message> _messages = [];

  bool _isTyping = false;
  bool _hasText = false;
  bool _isListening = false;

  late final stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    _loadChatHistory();

    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText && mounted) {
        setState(() => _hasText = hasTextNow);
      }
    });
  }

  // ================= LOAD CHAT HISTORY =================
  Future<void> _loadChatHistory() async {
    try {
      final history = await ChatService.fetchChatHistory();
      if (!mounted) return;

      _messages.clear();

      for (final msg in history) {
        final String? text = msg['message']?.toString();
        final String? role = msg['role']?.toString();
        final String? createdAt = msg['created_at']?.toString();

        if (text == null || role == null) continue;

        _messages.add(
          Message(
            text: text,
            isUser: role == 'user',
            timestamp: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
          ),
        );
      }

      setState(() {});
      _scrollToBottom();
    } catch (_) {
      // silently fail – no crash
    }
  }

  // ================= SAFE SCROLL =================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ================= SEND MESSAGE =================
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    final userMessage = Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final reply = await ChatService.sendMessage(text);
      if (!mounted) return;

      final botMessage = Message(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _isTyping = false;
        _messages.add(botMessage);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add(
          Message(
            text: "I'm having trouble connecting right now.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    _scrollToBottom();
  }

  // ================= SPEECH TO TEXT =================
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (!available || !mounted) return;

    setState(() => _isListening = true);

    _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MindEaseAI Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// CHAT MESSAGES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "MindEaseAI is typing...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          /// INPUT BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText:
                          _isListening ? "Listening..." : "Type your message...",
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? CircleAvatar(
                          key: const ValueKey("send"),
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon:
                                const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
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
