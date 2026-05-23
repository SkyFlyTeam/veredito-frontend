import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/shared/screens/home_screen.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/providers/petition_upload_provider.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/view_models/petition_upload_state.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/view_models/petition_upload_view_model.dart';
import 'package:flutter_cookiecutter/features/petition/domain/use_cases/upload_petition_usecase.dart';
import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import 'package:flutter_cookiecutter/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class FakeStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data[key] = value ?? '';
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }
}

class MockUploadPetitionUsecase extends Mock implements UploadPetitionUsecase {}

class TestSessionNotifier extends SessionNotifier {
  TestSessionNotifier(User? initialUser) : super() {
    state = initialUser;
  }
}

class TestApiClient extends ApiClient {
  TestApiClient() : super(Dio(), Dio(), Dio(), FakeStorage());
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:3000');
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Role-Based Home Screens Greeting Tests', () {
    late MockUploadPetitionUsecase mockUsecase;

    setUp(() {
      mockUsecase = MockUploadPetitionUsecase();
    });

    testWidgets('HomeScreen deve exibir conteúdo correto para juiz', (tester) async {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'Gerson',
        sobrenome: 'Silva',
        email: 'g@j.com',
        role: 'juiz',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(TestApiClient()),
            sessionProvider.overrideWith((ref) => TestSessionNotifier(user)),
            petitionUploadProvider.overrideWith(
              (ref) => PetitionUploadViewModel(mockUsecase),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Olá, Gerson!'), findsOneWidget);
      expect(find.text('Petição inicial'), findsOneWidget);
      expect(find.text('Processos'), findsOneWidget);
    });

    testWidgets('AdvogadoHomeScreen deve exibir saudação correta', (
      tester,
    ) async {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'Gerson',
        sobrenome: 'Silva',
        email: 'g@a.com',
        role: 'advogado',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(TestApiClient()),
            sessionProvider.overrideWith((ref) => TestSessionNotifier(user)),
            petitionUploadProvider.overrideWith(
              (ref) => PetitionUploadViewModel(mockUsecase),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Olá, Gerson!'), findsOneWidget);
      expect(find.text('Enviar Petição Inicial'), findsOneWidget);
    });

    testWidgets('HomeScreen deve exibir conteúdo correto para usuário comum', (tester) async {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'Gerson',
        sobrenome: 'Silva',
        email: 'g@u.com',
        role: 'user',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(TestApiClient()),
            sessionProvider.overrideWith((ref) => TestSessionNotifier(user)),
            petitionUploadProvider.overrideWith(
              (ref) => PetitionUploadViewModel(mockUsecase),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Olá, Gerson!'), findsOneWidget);
      expect(find.text('Enviar Petição Inicial'), findsOneWidget);
    });
  });
}
