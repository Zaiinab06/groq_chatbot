import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/groq_api_service.dart';
import '../models/chat_message.dart';

final groqApiProvider = Provider((ref) => GroqApiService());

final streamingResponseProvider = StateProvider<String>((ref) => "");
final isStreamingProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GroqApiService _apiService;
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

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  return ChatNotifier(ref.watch(groqApiProvider), ref);
});
