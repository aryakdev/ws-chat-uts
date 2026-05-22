import 'package:flutter/foundation.dart';

import 'package:mobile_flutter/model/chat_user.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/services/chat_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';

class ChatDashboardController {
  ChatDashboardController({WebSocketService? webSocketService})
      : _webSocketService = webSocketService ?? WebSocketService();

  final WebSocketService _webSocketService;

  ChatModel? selectedChat;
  String? selectedRoomId;
  bool isLoading = false;
  List<ChatModel> chats = [];

  Future<void> init() async {
    await fetchUsers();
    await _webSocketService.initWS();
    Future.delayed(const Duration(seconds: 2), () {
      sendTestMessage();
    });
  }

  void sendTestMessage() {
    _webSocketService.sendMessage("halo dari flutter");
  }

  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      final response = await ApiClient().get('/api/users');
      if (response.statusCode == 200) {
        final json = response.data;
        final List users = json['data'];

        chats = users.map<ChatModel>((user) {
          return ChatModel(
            id: user['id'].toString(),
            name: user['username'],
            lastMessage: '',
            time: '',
          );
        }).toList();

        print("TOTAL CHATS : ${chats.length}");
      }
    } catch (e) {
      debugPrint('fetchUsers error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<String?> openRoom(ChatModel chat) async {
    await _webSocketService.reconnectIfNeeded();

    final accessToken = await ApiClient().getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final roomId = await ChatService().createPrivateService(
      targetUserId: chat.id,
    );

    selectedChat = chat;
    selectedRoomId = roomId;
    return roomId;
  }

  void clearSelectedChat() {
    selectedChat = null;
  }

  void dispose() {
    _webSocketService.disconnect();
  }
}