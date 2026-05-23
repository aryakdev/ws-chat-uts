class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String type;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      roomId: json["room_id"],
      senderId: json["sender_id"],
      content: json["content"],
      type: json["type"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "room_id": roomId,
      "sender_id": senderId,
      "content": content,
      "type": type,
      "created_at": createdAt.toIso8601String(),
    };
  }
}