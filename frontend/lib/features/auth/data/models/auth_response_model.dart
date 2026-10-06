class AuthResponseModel {
  final String token;
  final String refreshToken;
  final String email;
  final String username;
  final int id;

  AuthResponseModel({
    required this.token,
    required this.refreshToken,
    required this.email,
    required this.username,
    required this.id,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
      email: json['email'],
      username: json['username'],
      id: json['id'],
    );
  }
}