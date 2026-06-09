import 'package:mobile_flutter/services/api_client_services.dart';
import '../model/message_model.dart';
import '../domain/repositories/message_repository.dart';

class MessageService implements MessageRepository {
  final ApiClient apiClient;
  MessageService(this.apiClient);
  
  @override
  Future<List<MessageModel>> fetchMessages(
    String roomId,
    String token,
  ) async {
    final response = await ApiClient().dio.get(
      '/api/messages/$roomId', 
    );
   

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
}