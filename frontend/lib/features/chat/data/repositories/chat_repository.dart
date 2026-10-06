import 'package:dio/dio.dart';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/features/chat/data/models/message_model.dart';
import 'package:frontend_app/features/chat/data/models/user_model.dart';

class ChatRepository {
  final DioClient dioClient;

  ChatRepository(this.dioClient);

  Future<List<MessageModel>> getConversation(int otherUserId) async {
    try {
      final response = await dioClient.dio.get(
        '/chat/conversation/$otherUserId',
      );
      return (response.data as List)
          .map((message) => MessageModel.fromJson(message))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await dioClient.dio.get('/chat/users');
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<void> markAsRead(int otherUserId) async {
    try {
      await dioClient.dio.post('/chat/read/$otherUserId');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<Map<int, int>> getUnreadCounts() async {
    try {
      final response = await dioClient.dio.get('/chat/unread-counts');

      // حماية: لو الرد مش Map، نرجع Map فاضية
      if (response.data is! Map) {
        return {};
      }

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return data.map((key, value) {
        // حماية: لو القيمة مش int، نتجاهلها
        if (value is int) {
          return MapEntry(int.parse(key), value);
        }
        return MapEntry(int.parse(key), 0);
      });
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<int> getUnreadTotal() async {
    try {
      final response = await dioClient.dio.get('/chat/unread-total');
      if (response.data is int) {
        return response.data as int;
      }
      return 0;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
