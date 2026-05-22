import 'package:dio/dio.dart';
import 'package:mobile_flutter/services/api_client.dart';

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

      final roomId = response.data['room_id']?.toString();

      // tambahan penting untuk lihat flow backend
      final status = response.data['status'];
      if (status != null) {
        // expected: "created" | "existing"
      } else {
      }

      if (roomId == null || roomId.isEmpty) {
        throw Exception('room_id is missing from response');
      }
   

      return roomId;
    } on DioException catch (e) {
      print(" [DIO ERROR]");
      print("Status: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print(" [UNKNOWN ERROR] $e");
      rethrow;
    }
  }
}