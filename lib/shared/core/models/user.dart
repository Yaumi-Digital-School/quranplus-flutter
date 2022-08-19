import 'package:equatable/equatable.dart';

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
