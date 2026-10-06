import 'package:dio/dio.dart';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import 'package:frontend_app/features/chat/data/models/message_model.dart';
import 'package:frontend_app/features/chat/data/models/user_model.dart';

class ChatRepository {
  final DioClient dioClient;

  ChatRepository(this.dioClient);

  Future<List<MessageModel>> getConversation(int otherUserId) async {
    String? token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await dioClient.dio.get(
        '/chat/conversation/$otherUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final messages = (response.data as List)
          .map((message) => MessageModel.fromJson(message))
          .toList();
      return messages;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');
    try {
      final response = await dioClient.dio.get(
        '/chat/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
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
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      await dioClient.dio.post(
        '/chat/read/$otherUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<Map<int, int>> getUnreadCounts() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await dioClient.dio.get(
        '/chat/unread-counts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // response.data هي Map<String, dynamic> من JSON
      // لازم نحولها لـ Map<int, int>
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(int.parse(key), value as int));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<int> getUnreadTotal() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');
    try {
      final response = await dioClient.dio.get(
        '/chat/unread-total',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as int;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
