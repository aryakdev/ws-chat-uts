import 'package:mobile_flutter/services/api_client.dart';
import '../model/message_model.dart';
import '../domain/repositories/message_repository.dart';

class MessageService implements MessageRepository {

  Future<List<MessageModel>> fetchMessages(
    String roomId,
    String token,
  ) async {
    final response = await ApiClient().dio.get(
      '/api/messages/$roomId', 
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.data}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load messages");
    }

    final json = response.data as Map<String, dynamic>;

    if (json["success"] != true) {
      print("Response not successful: ${json['message']}");
      return [];
    }

    final List data = json["data"] ?? [];
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  @override
  Future<void> sendMessage(String roomId, String content, String token) async {
    print("sendMessage not yet implemented");
  }
}