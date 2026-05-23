import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:mobile_flutter/services/api_client.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  WebSocketChannel? get channel => _channel;
  
  void Function(String message)? onMessage; 

  Future<void> initWS() async {
    try {
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
      await initWS();
    }
  }


  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  
}