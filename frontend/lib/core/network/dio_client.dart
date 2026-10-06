import 'package:dio/dio.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;
  late final Dio _refreshDio;  // Dio منفصل عشان نعمل refresh

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // لو التوكن انتهى (401)، جرب جدده
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              // أعد المحاولة بنفس الطلب
              final newToken = await TokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['token'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await TokenStorage.saveAccessToken(newAccessToken);
      await TokenStorage.saveRefreshToken(newRefreshToken);
      return true;
    } catch (e) {
      // لو فشل التجديد، امسح التوكنات
      await TokenStorage.clearTokens();
      return false;
    }
  }
}