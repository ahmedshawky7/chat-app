import 'dart:convert';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter/foundation.dart';
class WebsocketService {
  StompClient? _stompClient;
  final DioClient dioClient;
  Function(Map<String, dynamic>)? _onMessageReceived;

  WebsocketService(this.dioClient);

  Future<void> connect(void Function(Map<String, dynamic>) onMessageReceived) async {
    _onMessageReceived = onMessageReceived;

    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws/websocket',
        onConnect: _onConnect,
        onWebSocketError: _onError,
        onStompError: _onStompError,
        onDisconnect: _onDisconnect,
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('Connected to WebSocket');
    _stompClient!.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null && _onMessageReceived != null) {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          _onMessageReceived!(data);
        }
      },
    );
  }

  void sendMessage(int receiverId, String content) {
    final message = {
      'receiverId': receiverId,
      'content': content,
    };
    _stompClient!.send(
      destination: '/app/chat.send',
      body: jsonEncode(message),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  void _onError(dynamic error) {
    debugPrint('WebSocket error: $error');
  }

  void _onStompError(StompFrame frame) {
    debugPrint('STOMP error: ${frame.body}');
  }

  void _onDisconnect(StompFrame frame) {
    debugPrint('Disconnected: ${frame.body}');
  }
}