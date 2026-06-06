import 'package:mobile_flutter/model/message_model.dart';

class ChatRoomModel {
  final String id;
  final String name;
  final String avatarUrl;

  final MessageModel? lastMessage;

  final int unreadCount;

  ChatRoomModel({
    required this.id,
    required this.name,
    this.avatarUrl = "",
    this.lastMessage,
    this.unreadCount = 0,
  });
}