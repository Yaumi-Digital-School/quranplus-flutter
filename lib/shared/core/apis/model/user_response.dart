import 'package:qurantafsir_flutter/shared/core/models/user.dart';

class UserResponse {
  UserResponse({
    this.message,
    this.errorMessage,
    this.token,
    this.data,
  });

  String? message;
  String? errorMessage;
  String? token;
  User? data;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];

    return UserResponse(
      message: json['message'] ?? '',
      errorMessage: json['error_message'] ?? '',
      token: (data == null) ? '' : (data['access_token'] ?? ''),
      data: (data == null) ? User.empty : User.fromJson(json['data']),
    );
  }
}
