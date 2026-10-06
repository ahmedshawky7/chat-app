import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/login_request_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final request = RegisterRequestModel(
        email: email,
        username: username,
        password: password,
      );
      final response = await authRepository.register(request);
      emit(
        AuthSuccess(
          response.token,
          response.refreshToken,
          response.email,
          response.username,
          response.id,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestModel(email: email, password: password);
      final response = await authRepository.login(request);
      emit(
        AuthSuccess(
          response.token,
          response.refreshToken,
          response.email,
          response.username,
          response.id,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
