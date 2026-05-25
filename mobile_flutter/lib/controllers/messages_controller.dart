import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/message_model.dart';
import '../services/messages_service.dart';
import '../services/websocket_service.dart';

class MessageState {
  final List<MessageModel> messages;
  final bool isLoading;

  const MessageState({
    required this.messages,
    required this.isLoading,
  });

  MessageState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MessageCubit extends Cubit<MessageState> {
  final MessageService service;

  MessageCubit(this.service)
      : super(const MessageState(
          messages: [],
          isLoading: false,
        ));

  // ✅ FIXED LOAD MESSAGES
  Future<void> loadMessages(String roomId, String token) async {
    print('🚀 loadMessages START');

    emit(state.copyWith(isLoading: true));

    try {
      final data = await service.fetchMessages(roomId, token);

      emit(state.copyWith(
        isLoading: false,
        messages: data,
      ));

      print('✅ Messages loaded: ${data.length}');
    } catch (e, stack) {
      print('❌ ERROR loadMessages: $e');
      print(stack);

      emit(state.copyWith(isLoading: false));
    }
  }
  
  void addRealtimeMessage(MessageModel message) {
    emit(state.copyWith(
      messages: [...state.messages, message],
    ));
  }

  void clearMessages() {
    emit(const MessageState(
      messages: [],
      isLoading: false,
    ));
  }

  void bindWebSocket(WebSocketService ws, String roomId) {
    ws.onMessage = (raw) {
      final data = jsonDecode(raw);
      final message = MessageModel.fromJson(data);

      if (message.roomId == roomId) {
        addRealtimeMessage(message);
      }
    };

    ws.initWS();
  }
}