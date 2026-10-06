import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebsocketService {
  StompClient? _stompClient;
  final DioClient dioClient;
  Function(Map<String, dynamic>)? _onMessageReceived;
  Function(Map<String, dynamic>)? _onReadReceipt;

  WebsocketService(this.dioClient);

  Future<void> connect(
    void Function(Map<String, dynamic>) onMessageReceived,
    void Function(Map<String, dynamic>) onReadReceipt,
  ) async {
    _onMessageReceived = onMessageReceived;
    _onReadReceipt = onReadReceipt;

    // لو الاتصال شغال، متعملش اتصال جديد
    if (_stompClient != null) {
      return;
    }

    final token = await TokenStorage.getAccessToken();
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

    // Subscription 1: messages
    _stompClient!.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null && _onMessageReceived != null) {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          _onMessageReceived!(data);
        }
      },
    );

    // Subscription 2: read receipts ← جديد
    _stompClient!.subscribe(
      destination: '/user/queue/reads',
      callback: (frame) {
        if (frame.body != null && _onReadReceipt != null) {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          _onReadReceipt!(data);
        }
      },
    );
  }

  void sendMessage(int receiverId, String content) {
    final message = {'receiverId': receiverId, 'content': content};
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
