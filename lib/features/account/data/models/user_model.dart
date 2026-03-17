import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String acessLevel;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.acessLevel,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      acessLevel: json['acessLevel'],
      token: json['token'],
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      acessLevel: acessLevel,
      token: token,
    );
  }
}
