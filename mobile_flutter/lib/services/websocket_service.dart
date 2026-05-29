import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:mobile_flutter/services/api_client.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  WebSocketChannel? get channel => _channel;
  
  late final String _instanceId;
  void Function(String message)? onMessage;

  WebSocketService() {
    _instanceId = Random().nextInt(100000).toString();
  } 

  Future<void> initWS() async {
    try {
      debugPrint('🌐 WebSocketService($_instanceId).initWS() called - creating new connection');
      
      String ipAddress = "127.0.0.1";
      if (kIsWeb) {
        ipAddress = "localhost";
      } else if (Platform.isAndroid) {
        ipAddress = "10.0.2.2";
      }

      final accessToken = await ApiClient().getAccessToken();
      
      final String wsString = kIsWeb && accessToken != null && accessToken.isNotEmpty
          ? "ws://$ipAddress:8080/ws?token=$accessToken"
          : "ws://$ipAddress:8080/ws";

      final wsUrl = Uri.parse(wsString);
      debugPrint('🌐 WebSocketService($_instanceId) connecting to: $wsUrl');

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

      debugPrint('🌐 WebSocketService($_instanceId) connected successfully');
      
      _channel?.stream.listen(
      (message) {
        debugPrint("Pesan masuk WS: $message");

        onMessage?.call(message);
      },
      onError: (error) => debugPrint("Error WS: $error"),
      onDone: () => debugPrint("Koneksi WS putus."),
    );
    } catch (e) {
      debugPrint(" Gagal WS: $e");
    }
  }

  @visibleForTesting
void injectChannel(WebSocketChannel channel) {
  _channel = channel;
  _channel?.stream.listen(
    (message) {
      debugPrint("Pesan masuk WS: $message");
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
      debugPrint(
        "Gagal kirim, koneksi WebSocket belum siap!",
      );
      return;
    }

    final payload = {
      "Room_id": roomId,
      "Content": content,
      "Type": "text",
    };

    _channel?.sink.add(
      jsonEncode(payload),
    );
  }

  Future<void> reconnectIfNeeded() async {
    if (_channel == null) {
      debugPrint('🔌 WebSocketService($_instanceId) channel was null, reconnecting...');
      await initWS();
    } else {
      debugPrint('✅ WebSocketService($_instanceId) already connected, skipping init');
    }
  }


  void disconnect() {
    debugPrint('❌ WebSocketService($_instanceId) disconnecting...');
    _channel?.sink.close();
    _channel = null;
    debugPrint('❌ WebSocketService($_instanceId) disconnected');
  }

  
}