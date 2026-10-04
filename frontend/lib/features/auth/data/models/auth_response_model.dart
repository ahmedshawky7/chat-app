class AuthResponseModel {
  final String token;
  final String email;
  final int id;

  AuthResponseModel({required this.token, required this.email, required this.id});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      email: json['email'],
      id: json['id'],
    );
  }
}