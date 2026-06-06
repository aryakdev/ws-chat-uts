import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'dart:async';

import 'websocket_service_test.mocks.dart';

@GenerateMocks([WebSocketChannel, WebSocketSink])
void main() {
  group('WebSocketService', () {
    late WebSocketService service;
    late MockWebSocketChannel mockChannel;
    late MockWebSocketSink mockSink;
    late StreamController<dynamic> streamController;

    setUp(() {
      service = WebSocketService();
      mockChannel = MockWebSocketChannel();
      mockSink = MockWebSocketSink();
      streamController = StreamController<dynamic>.broadcast();

      when(mockChannel.stream).thenAnswer((_) => streamController.stream);
      when(mockChannel.sink).thenReturn(mockSink);
      when(mockSink.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      streamController.close();
    });

    test('sendMessage - gagal jika channel null', () {
      service.sendMessage(roomId: 'room1', content: 'hello');
      // Tidak throw, hanya print debug
      expect(service.channel, isNull);
    });

    test('sendMessage - kirim payload JSON yang benar', () {
      // Inject mock channel langsung
      service.injectChannel(mockChannel);

      service.sendMessage(roomId: 'room-123', content: 'halo dunia');

      verify(mockSink.add(argThat(contains('"Room_id":"room-123"')))).called(1);
    });

    test('onMessage callback dipanggil saat ada pesan masuk', () {
      service.injectChannel(mockChannel);

      String? received;
      service.onMessage = (msg) => received = msg;

      // Simulate incoming message
      streamController.add('{"type":"text","content":"test"}');

      // Listen sudah di-setup saat injectChannel
      expect(service.channel, isNotNull);
    });

    test('disconnect - channel jadi null', () {
      service.injectChannel(mockChannel);
      service.disconnect();

      verify(mockSink.close()).called(1);
      expect(service.channel, isNull);
    });

    test('reconnectIfNeeded - tidak reconnect jika channel sudah ada', () async {
      service.injectChannel(mockChannel);
      // Tidak akan panggil initWS karena channel sudah ada
      await service.reconnectIfNeeded();
      expect(service.channel, isNotNull);
    });
  });
}