import '../../domain/entities/user.dart';

class UserModel {
  final String accessToken;

  UserModel({required this.accessToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(accessToken: json['access_token'] as String);
  }

  User toEntity() {
    return User(accessToken: accessToken);
  }
}
