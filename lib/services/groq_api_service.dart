import 'dart:convert';
//import 'dart00:00:19.json';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import '../models/chat_response.dart';

abstract interface class IChatApiService {
  Stream<Either<String, String>> streamChat(String message);
}

class GroqApiService implements IChatApiService {
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  final String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  @override
  Stream<Either<String, String>> streamChat(String message) async* {
    final client = http.Client();

    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));

      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      });

      request.body = jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {"role": "user", "content": message},
        ],
        "stream": true,
      });

      final response = await client.send(request);

      if (response.statusCode == 200) {
        yield* response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .map<Either<String, String>>((line) {
              if (line.isEmpty) return const Right('');
              if (!line.startsWith('data: ')) return const Right('');

              final dataContent = line.substring(6).trim();
              if (dataContent == '[DONE]') return const Right('');

              try {
                final jsonMap = jsonDecode(dataContent) as Map<String, dynamic>;
                return ChatStreamChunk.fromJson(
                  jsonMap,
                ).fold((error) => Left(error), (chunk) => Right(chunk.content));
              } catch (e) {
                return Left("Streaming error: $e");
              }
            });
      } else {
        final errorResponseBody = await response.stream.bytesToString();
        yield Left("Server Error (${response.statusCode}): $errorResponseBody");
      }
    } catch (e) {
      yield Left("Network exception: $e");
    }
  }
}
