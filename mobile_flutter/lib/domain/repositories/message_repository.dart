import '../../model/message_model.dart';

abstract class MessageRepository {
  Future<List<MessageModel>> fetchMessages(String roomId, String token);
  Future<void> sendMessage(String roomId, String content, String token);
}
