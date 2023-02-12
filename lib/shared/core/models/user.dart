import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

class User extends Equatable {
  const User({
    required this.name,
    required this.email,
    this.birthDate = '',
    this.gender = '',
  });

  final String name;
  final String email;
  final String birthDate;
  final String gender;

  static const empty = User(name: '', email: '');

  bool get isEmpty => this == User.empty;

  bool get isNotEmpty => this != User.empty;

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        birthDate: json['birth_date'] ?? '',
        gender: json['gender'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'birth_date': birthDate,
        'gender': gender,
      };

  @override
  List<Object?> get props => [
        name,
        email,
        birthDate,
        gender,
      ];
}

@JsonSerializable()
class RegisterOrLoginRequest {
  const RegisterOrLoginRequest({
    this.name,
    this.email,
    this.appleTokenID,
  });

  final String? name;
  final String? email;
  @JsonKey(name: 'apple_token_id')
  final String? appleTokenID;

  factory RegisterOrLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterOrLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterOrLoginRequestToJson(this);
}
