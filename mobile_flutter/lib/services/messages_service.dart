import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/message_model.dart';
import '../domain/repositories/message_repository.dart';

class MessageService implements MessageRepository {
  final String baseUrl = "http://192.168.33.56:8080/api";

  Future<List<MessageModel>> fetchMessages(
    String roomId,
    String token,
  ) async {
    final url = Uri.parse("$baseUrl/messages/$roomId");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("URL: ${response.request?.url}");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load messages");
    }

    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print("DECODED JSON: $json");
      
      if (json["success"] != true) {
        print("Response not successful: ${json['message']}");
        return [];
      }
      
      final List data = json["data"] ?? [];
      print("DATA COUNT: ${data.length}");

      return data.map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      print("ERROR parsing response: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String roomId, String content, String token) async {
    // TODO: Implement sendMessage API call
    print("sendMessage not yet implemented");
  }
}