import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/core/errors/api_exception.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/register_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/providers/register_usecase_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/view_models/register_state.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/view_models/register_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late ProviderContainer container;
  late RegisterViewModel viewModel;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();

    container = ProviderContainer(
      overrides: [
        registerViewModelProvider.overrideWith(
          (ref) => RegisterViewModel(mockRegisterUsecase, ref),
        ),
      ],
    );

    viewModel = container.read(registerViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('RegisterViewModel', () {
    test('should initialize with default state', () {
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNull);
    });

    test('should register successfully', () async {
      when(
        () => mockRegisterUsecase.execute(
          'Nome Teste',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).thenAnswer((_) async {});

      await viewModel.register('Nome Teste', 'teste@exemplo.com', 'Senha@123');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNull);

      verify(
        () => mockRegisterUsecase.execute(
          'Nome Teste',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).called(1);
    });

    test('should clear previous error before attempting again', () async {
      when(
        () => mockRegisterUsecase.execute(
          'Primeira Tentativa',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).thenThrow(const ApiException(message: 'Email já cadastrado'));

      when(
        () => mockRegisterUsecase.execute(
          'Segunda Tentativa',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).thenAnswer((_) async {});

      await viewModel.register(
        'Primeira Tentativa',
        'teste@exemplo.com',
        'Senha@123',
      );
      expect(viewModel.state.error, 'Email já cadastrado');

      final states = <RegisterState>[];
      final listener = container.listen<RegisterState>(
        registerViewModelProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      await viewModel.register(
        'Segunda Tentativa',
        'teste@exemplo.com',
        'Senha@123',
      );

      expect(states.first.isLoading, true);
      expect(states.first.error, isNull);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNull);

      listener.close();
    });

    test(
      'should expose ApiException message when registration fails',
      () async {
        when(
          () => mockRegisterUsecase.execute(
            'Nome Teste',
            'teste@exemplo.com',
            'Senha@123',
          ),
        ).thenThrow(
          const ApiException(
            message: 'Erro de regra de negócio',
            statusCode: 409,
          ),
        );

        await viewModel.register(
          'Nome Teste',
          'teste@exemplo.com',
          'Senha@123',
        );

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.error, 'Erro de regra de negócio');
      },
    );

    test('should return default message for unexpected error', () async {
      when(
        () => mockRegisterUsecase.execute(
          'Nome Teste',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).thenThrow(Exception('falha inesperada'));

      await viewModel.register('Nome Teste', 'teste@exemplo.com', 'Senha@123');

      expect(viewModel.state.isLoading, false);
      expect(
        viewModel.state.error,
        'Ocorreu um erro ao registrar. Por favor, tente novamente.',
      );
    });

    test('should emit loading state during execution', () async {
      final states = <RegisterState>[];
      final listener = container.listen<RegisterState>(
        registerViewModelProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      when(
        () => mockRegisterUsecase.execute(
          'Nome Teste',
          'teste@exemplo.com',
          'Senha@123',
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      });

      await viewModel.register('Nome Teste', 'teste@exemplo.com', 'Senha@123');

      expect(states.length, 2);
      expect(states[0].isLoading, true);
      expect(states[0].error, isNull);
      expect(states[1].isLoading, false);
      expect(states[1].error, isNull);

      listener.close();
    });

    test('should forward arguments exactly as received', () async {
      when(
        () => mockRegisterUsecase.execute(
          '  Nome Com Espaços  ',
          '  teste@exemplo.com  ',
          '  Senha@123  ',
        ),
      ).thenAnswer((_) async {});

      await viewModel.register(
        '  Nome Com Espaços  ',
        '  teste@exemplo.com  ',
        '  Senha@123  ',
      );

      verify(
        () => mockRegisterUsecase.execute(
          '  Nome Com Espaços  ',
          '  teste@exemplo.com  ',
          '  Senha@123  ',
        ),
      ).called(1);
    });
  });
}
