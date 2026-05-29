import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  WebSocketService? _ws;

  MessageCubit(this.service, {WebSocketService? webSocketService})
      : _ws = webSocketService,
        super(const MessageState(
          messages: [],
          isLoading: false,
        ));

  Future<void> loadMessages(String roomId, String token) async {
     emit(state.copyWith(isLoading: true, messages: []));
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
  void reset() {
  emit(state.copyWith(messages: [], isLoading: false));
}

  void bindWebSocket(String roomId) {
  final alreadyHadWs = _ws != null;

  if (!alreadyHadWs) {
    _ws = WebSocketService();
  }

  _ws!.onMessage = (raw) {
    final data = jsonDecode(raw);
    final message = MessageModel.fromJson(data);

    if (message.roomId == roomId) {
      addRealtimeMessage(message);
    }
  };

  if (alreadyHadWs) {
    debugPrint('🔄 Reusing existing WebSocket instance for room: $roomId');
    _ws!.reconnectIfNeeded();
  } else {
    debugPrint('🆕 Creating and initializing new WebSocket instance for room: $roomId');
    _ws!.initWS();
  }
}

    void disconnectSocket() {
      _ws?.disconnect();
      _ws = null;

      print('🔌 WebSocket disconnected');
    } 
}