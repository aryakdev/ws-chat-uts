import 'dart:io' show Platform;
import 'dart:math' show Random;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:mobile_flutter/services/api_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketChannel? _channel;
  WebSocketChannel? get channel => _channel;
  
  StreamSubscription? _subscription;
  late final String _instanceId;
  void Function(String message)? onMessage;

  WebSocketService._internal() {
    _instanceId = Random().nextInt(100000).toString();
  } 

  Future<void> initWS() async {
    try {
      debugPrint('🌐 WebSocketService($_instanceId).initWS() called');
      
      await _subscription?.cancel();
      _subscription = null;
      
      String ipAddress = "192.168.1.47";

      final accessToken = await ApiClient().getAccessToken();
      
      final String wsString = accessToken != null && accessToken.isNotEmpty
          ? "ws://$ipAddress:8080/ws?token=$accessToken"
          : "ws://$ipAddress:8080/ws";

      final wsUrl = Uri.parse(wsString);
      debugPrint('🌐 WebSocketService connecting to: $wsUrl');

      if (kIsWeb) {
        _channel = WebSocketChannel.connect(wsUrl);
      } else {
        _channel = IOWebSocketChannel.connect(
          wsUrl,
          headers: {
            if (accessToken != null && accessToken.isNotEmpty)
              'Authorization': 'Bearer $accessToken',
          },
        );
      }

      _subscription = _channel?.stream.listen(
      (message) {
        try {
          final Map<String, dynamic> raw = jsonDecode(message);
          
          final fixedJson = {
            "id": raw["ID"] ?? raw["id"] ?? "",
            "room_id": raw["RoomID"] ?? raw["room_id"] ?? "",
            "sender_id": raw["SenderID"] ?? raw["sender_id"] ?? "",
            "content": raw["Content"] ?? raw["content"] ?? "",
            "type": raw["Type"] ?? raw["type"] ?? "text",
            "created_at": raw["CreatedAt"] ?? raw["created_at"] ?? DateTime.now().toIso8601String(),
          };
          
          onMessage?.call(jsonEncode(fixedJson));
        } catch (e) {
          onMessage?.call(message);
        }
      },
      onError: (error) => debugPrint("Error WS: $error"),
      onDone: () => debugPrint("Koneksi WS putus."),
    );
    } catch (e) {
      debugPrint("Gagal WS: $e");
    }
  }

  @visibleForTesting
  void injectChannel(WebSocketChannel channel) {
    _subscription?.cancel();
    _subscription = null;
    
    _channel = channel;
    _subscription = _channel?.stream.listen(
      (message) {
        onMessage?.call(message);
      },
      onError: (error) => debugPrint("Error WS: $error"),
      onDone: () => debugPrint("Koneksi WS putus."),
    );
  }

  void sendMessage({
    required String roomId,
    required String content,
  }) {
    if (_channel == null) {
      return;
    }

    final payload = {
      "action": "message",
      "room_id": roomId,
      "content": content,
      "type": "text",
    };

    _channel?.sink.add(jsonEncode(payload));
  }

  void sendJoin(String roomId) {
    if (_channel == null) {
      return;
    }

    final payload = {
      'action': 'join',
      'room_id': roomId,
    };

    _channel?.sink.add(jsonEncode(payload));
  }

  void sendLeave(String roomId) {
    if (_channel == null) {
      return;
    }

    final payload = {
      'action': 'leave',
      'room_id': roomId,
    };

    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> reconnectIfNeeded() async {
    if (_channel == null) {
      await initWS();
    } else {
      debugPrint('✅ WS already connected');
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }
}