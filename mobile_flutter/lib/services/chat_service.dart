import 'package:dio/dio.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final Dio _dio;

  ChatService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<String> createPrivateService({
    required String targetUserId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat/private',
        data: {'target_user_id': targetUserId},
      );

      debugPrint("=== CREATE PRIVATE ROOM RESPONSE: ${response.data}");

      final roomId = response.data['room_id']?.toString();
      final status = response.data['status'];

      if (status != null) {
      } else {
      }

      if (roomId == null || roomId.isEmpty) {
        throw Exception('room_id is missing from response');
      }

      return roomId;
    } on DioException catch (e) {
      debugPrint("[DIO ERROR] Status: ${e.response?.statusCode}");
      debugPrint("[DIO ERROR] Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("[UNKNOWN ERROR] $e");
      rethrow;
    }
  }
}