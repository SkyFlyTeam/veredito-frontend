class User {
  final String accessToken;
  final int id;
  final String nome;
  final String sobrenome;
  final String email;
  final String role;

  User({
    required this.accessToken,
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.role,
  });
}