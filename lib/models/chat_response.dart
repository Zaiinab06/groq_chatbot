import 'package:fpdart/fpdart.dart';

class ChatStreamChunk {
  final String content;

  ChatStreamChunk({required this.content});

  // fpdart format mein safe JSON parsing
  static Either<String, ChatStreamChunk> fromJson(Map<String, dynamic> json) {
    return Either.tryCatch(() {
      final choices = json['choices'] as List;
      if (choices.isEmpty) return ChatStreamChunk(content: '');

      final delta = choices[0]['delta'] as Map<String, dynamic>;
      final content = delta['content'] as String? ?? '';

      return ChatStreamChunk(content: content);
    }, (error, stackTrace) => "JSON Parsing Error: $error");
  }
}
