import 'package:dio/dio.dart';
import 'package:frontend_app/core/constants/api_constants.dart';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import 'package:frontend_app/features/auth/data/models/auth_response_model.dart';
import 'package:frontend_app/features/auth/data/models/login_request_model.dart';
import 'package:frontend_app/features/auth/data/models/register_request_model.dart';

class AuthRepository {
  final DioClient dioClient;

  AuthRepository({required this.dioClient});

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );
      final authResponse = AuthResponseModel.fromJson(response.data);
      await TokenStorage.saveAccessToken(authResponse.token);
      await TokenStorage.saveRefreshToken(authResponse.refreshToken);
      return authResponse;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      final authResponse = AuthResponseModel.fromJson(response.data);
      await TokenStorage.saveAccessToken(authResponse.token);
      await TokenStorage.saveRefreshToken(authResponse.refreshToken);
      return authResponse;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
