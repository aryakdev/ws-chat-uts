import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:mobile_flutter/services/chat_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:mobile_flutter/controllers/messages_controller.dart';
import 'package:mobile_flutter/injection.dart';
// import 'dart:convert';

class ChatDetailController {
  ChatDetailController({
    WebSocketService? webSocketService,
    required this.messageCubit, 
  }) : _webSocketService = webSocketService ?? getIt<WebSocketService>();

  final WebSocketService _webSocketService;
  final MessageCubit messageCubit;
  
  WebSocketService get webSocketService => _webSocketService;

  ChatRoomModel? selectedChat;
  String? selectedRoomId;
  bool isLoading = false;
  List<ChatRoomModel> chats = [];

  Future<void> init() async {
    await fetchUsers();
    await _webSocketService.initWS();
    Future.delayed(const Duration(seconds: 2), () {
    });
    _webSocketService.onMessage = handleIncomingMessage;
  }

  void handleIncomingMessage (String message) {
    debugPrint(
      "Controller receive message : $message"
    );
  }

  void sendMessage({
    required String content,
  }) {
    if (selectedRoomId == null) {
      debugPrint("Room belum dipilih");
      return;
    }

    _webSocketService.sendMessage(
      roomId: selectedRoomId!,
      content: content,
    );
  }

  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      final response = await ApiClient().get('/api/users');
      if (response.statusCode == 200) {
        final json = response.data;
        final List users = json['data'];

        chats = users.map<ChatRoomModel>((user) {
          String avatar = user['avatar']?.toString() ?? 
                          user['avatar_url']?.toString() ?? 
                          user['avatarUrl']?.toString() ?? 
                          '';

          return ChatRoomModel(
            id: user['id'].toString(),
            name: user['username'],
            avatarUrl: avatar,
          );
        }).toList();

      }
    } catch (e) {
      debugPrint('fetchUsers error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<String?> openRoom(ChatRoomModel chat) async {
    debugPrint("OPEN ROOM START: ${chat.id}");

    await _webSocketService.reconnectIfNeeded();

    // Leave the previous room before joining a new one (BUG #2)
    if (selectedRoomId != null && selectedRoomId != chat.id) {
      _webSocketService.sendLeave(selectedRoomId!);
      debugPrint("LEFT ROOM: $selectedRoomId");
    }

    final roomId = await ChatService().createPrivateService(
      targetUserId: chat.id,
    );

    debugPrint("ROOM ID FROM SERVER: $roomId");

    selectedChat = chat;
    selectedRoomId = roomId;

    // Join the new room on the WS Hub (BUG #2)
    if (roomId != null) {
      _webSocketService.sendJoin(roomId);
      debugPrint("JOINED ROOM: $roomId");
    }

    debugPrint("SELECTED ROOM SET: $selectedRoomId");

    return roomId;
  }
  
  /// Sets the selected chat locally WITHOUT making any HTTP call.
  /// Use this in the dashboard when navigating to a chat —
  /// openRoom is the single caller that actually hits the API.
  void selectChat(ChatRoomModel chat) {
    selectedChat = chat;
  }

  void clearSelectedChat() {
    selectedChat = null;
  }
  
  void dispose() {
    _webSocketService.disconnect();
  }
}