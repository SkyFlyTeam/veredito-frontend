import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final String accessToken;
  final int id;
  final String nome;
  final String sobrenome;
  final String email;
  final String role;

  UserModel({
    required this.accessToken,
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String;

    // Decodifica o JWT sem verificar a assinatura (só leitura do payload)
    final jwt = JWT.decode(accessToken);
    final payload = jwt.payload as Map<String, dynamic>;

    return UserModel(
      accessToken: accessToken,
      id: payload['sub'] as int,
      nome: payload['nome'] as String,
      sobrenome: payload['sobrenome'] as String,
      email: payload['email'] as String,
      role: payload['role'] as String,
    );
  }

  factory UserModel.fromProfileJson(
    Map<String, dynamic> json,
    String accessToken,
  ) {
    return UserModel(
      accessToken: accessToken,
      id: json['id'] as int,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      email: json['email'] as String,
      role: json['role'] ?? (json['accessLevel']?['nome'] ?? ''),
    );
  }

  User toEntity() {
    return User(
      accessToken: accessToken,
      id: id,
      nome: nome,
      sobrenome: sobrenome,
      email: email,
      role: role,
    );
  }
}
