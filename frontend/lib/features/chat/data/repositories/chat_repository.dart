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
}
