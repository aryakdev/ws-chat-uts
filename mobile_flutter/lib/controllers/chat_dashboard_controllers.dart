import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/services/chat_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';

class ChatDashboardController {
  ChatDashboardController({WebSocketService? webSocketService})
  : _webSocketService = webSocketService ?? WebSocketService();

  final WebSocketService _webSocketService;

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
          return ChatRoomModel(
            id: user['id'].toString(),
            name: user['username'],
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

  final roomId = await ChatService().createPrivateService(
    targetUserId: chat.id,
  );

  debugPrint("ROOM ID FROM SERVER: $roomId");

  selectedChat = chat;
  selectedRoomId = roomId;

  debugPrint("SELECTED ROOM SET: $selectedRoomId");

  return roomId;
}
  

  void clearSelectedChat() {
    selectedChat = null;
  }

  void dispose() {
    _webSocketService.disconnect();
  }
}