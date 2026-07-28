import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/groq_api_service.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/chat_message.dart';

// 1. API Service Provider (DIP Abstraction)
final chatApiProvider = Provider<IChatApiService>((ref) => GroqApiService());

// 2. UI Helper States
final streamingResponseProvider = StateProvider<String>((ref) => "");
final isStreamingProvider = StateProvider<bool>((ref) => false);

// 3. Main Chat ViewModel Provider
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  return ChatNotifier(ref.watch(chatApiProvider), ref);
});
