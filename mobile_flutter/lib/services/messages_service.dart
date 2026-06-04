import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/message_model.dart';
import '../domain/repositories/message_repository.dart';

class MessageService implements MessageRepository {
  String get baseUrl {
    return 'http://192.168.1.47:8080/api';
  }

  @override
  Future<List<MessageModel>> fetchMessages(String roomId, String token) async {
    try {
      final url = Uri.parse("$baseUrl/messages/$roomId");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        if (decoded is Map<String, dynamic>) {
          if (decoded["success"] == true) {
            final List data = decoded["data"] ?? [];
            return data.map((e) => MessageModel.fromJson(e)).toList();
          }
        } else if (decoded is List) {
          return decoded.map((e) => MessageModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> sendMessage(String roomId, String content, String token) async {}
}