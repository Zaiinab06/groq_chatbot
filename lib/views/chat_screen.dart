import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    final isStreaming = ref.read(isStreamingProvider);

    if (text.isNotEmpty && !isStreaming) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(chatProvider);
    final isStreaming = ref.watch(isStreamingProvider);
    final streamingText = ref.watch(streamingResponseProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 115, 183, 217),
      appBar: AppBar(
        title: const Text(
          'Groq AI Chatbot 🚀',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            //  backgroundColor: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 9, 39, 90).withOpacity(0.1),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatMessages.isEmpty && !isStreaming
                  ? const Center(
                      child: Text(
                        'Ask me anything! 🤖',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: chatMessages.length + (isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatMessages.length) {
                          final msg = chatMessages[index];
                          return Align(
                            alignment: msg.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? Colors.blueAccent
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(
                                    msg.isUser ? 16 : 0,
                                  ),
                                  bottomRight: Radius.circular(
                                    msg.isUser ? 0 : 16,
                                  ),
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: RepaintBoundary(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  streamingText,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 24,
                top: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: isStreaming
                        ? Colors.grey
                        : Colors.blueAccent,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
