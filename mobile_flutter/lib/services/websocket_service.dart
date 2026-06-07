import 'dart:math' show Random;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:mobile_flutter/services/api_client_services.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  WebSocketChannel? get channel => _channel;
  StreamSubscription? _subscription;
  late final String _instanceId;
  void Function(String message)? onMessage;

  WebSocketService() {
    _instanceId = Random().nextInt(100000).toString();
  } 

  Future<void> initWS() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      
      final accessToken = ApiClient().accessToken;
      final wsBase = ApiClient().baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
      
      final String wsString = kIsWeb && accessToken != null && accessToken.isNotEmpty
          ? "$wsBase/ws?token=$accessToken"
          : "$wsBase/ws";

      final wsUrl = Uri.parse(wsString);

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
          onMessage?.call(message);
        },
      );
    } catch (e) {
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
    );
  }

  void sendMessage({
    required String roomId,
    required String content,
  }) {
    if (_channel == null) return;
    final payload = {
      "action": "message",
      "room_id": roomId,
      "content": content,
      "type": "text",
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  void sendJoin(String roomId) {
    if (_channel == null) return;
    final payload = {
      'action': 'join',
      'room_id': roomId,
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  void sendLeave(String roomId) {
    if (_channel == null) return;
    final payload = {
      'action': 'leave',
      'room_id': roomId,
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> reconnectIfNeeded() async {
    if (_channel == null) {
      await initWS();
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }
}