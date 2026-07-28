import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/groq_api_service.dart';
import '../models/chat_message.dart';
import '../providers/chat_providers.dart'; // 👈 Imports for Providers

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final IChatApiService _apiService;
  final Ref _ref;

  ChatNotifier(this._apiService, this._ref) : super([]);

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = [...state, ChatMessage(text: text, isUser: true)];

    _ref.read(isStreamingProvider.notifier).state = true;
    _ref.read(streamingResponseProvider.notifier).state = "";

    String accumulatedResponse = "";

    _apiService
        .streamChat(text)
        .listen(
          (eitherResult) {
            eitherResult.fold(
              (error) {
                accumulatedResponse = "Error: $error";
                _ref.read(streamingResponseProvider.notifier).state =
                    accumulatedResponse;
              },
              (chunk) {
                accumulatedResponse += chunk;

                _ref.read(streamingResponseProvider.notifier).state =
                    accumulatedResponse;
              },
            );
          },
          onDone: () {
            if (accumulatedResponse.isNotEmpty) {
              state = [
                ...state,
                ChatMessage(text: accumulatedResponse, isUser: false),
              ];
            }

            _ref.read(isStreamingProvider.notifier).state = false;
            _ref.read(streamingResponseProvider.notifier).state = "";
          },
        );
  }
}
