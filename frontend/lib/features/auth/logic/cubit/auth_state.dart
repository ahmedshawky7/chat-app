import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. الحالة الابتدائية
class AuthInitial extends AuthState {
  const AuthInitial();
}

// 2. حالة التحميل (Loading)
class AuthLoading extends AuthState {
  const AuthLoading();
}

// 3. حالة النجاح (Success)
class AuthSuccess extends AuthState {
  final String token;
  final String email;
  final int id;
  const AuthSuccess(this.token, this.email, this.id);

  @override
  List<Object?> get props => [token, email, id];
}
// 4. حالة الفشل (Error)
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}