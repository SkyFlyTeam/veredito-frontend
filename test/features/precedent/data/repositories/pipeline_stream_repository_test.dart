import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import '../../../../../lib/features/precedent/data/data_sources/pipeline_stream_data_source.dart';
import '../../../../../lib/features/precedent/data/models/pipeline_event_model.dart';
import '../../../../../lib/features/precedent/data/repositories/pipeline_stream_repository_impl.dart';

class FakeDio extends Fake implements Dio {}

class FakePipelineStreamDataSource implements PipelineStreamDataSource {
  Stream<PipelineEvent>? _stream;
  int? _lastPeticaoId;
  final Dio _dio = FakeDio();

  void setStream(Stream<PipelineEvent> stream) {
    _stream = stream;
  }

  int? getLastPeticaoId() => _lastPeticaoId;

  @override
  Stream<PipelineEvent> streamPipeline(int peticaoId) {
    _lastPeticaoId = peticaoId;
    return _stream ?? const Stream.empty();
  }

  @override
  Dio get dio => _dio;

  @override
  void cancelStream(int peticaoId) {}

  @override
  void cancelAll() {}
}

void main() {
  group('PipelineStreamRepository', () {
    late FakePipelineStreamDataSource fakeDataSource;
    late PipelineStreamRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakePipelineStreamDataSource();
      repository = PipelineStreamRepositoryImpl(fakeDataSource);
    });

    test('streamPipeline should emit SearchEvent correctly', () async {
      final precedent = PrecedentBackendDto(
        id: 932,
        numeroRegistro: 'tjpa-irdr-8',
        tese: 'I- É inconstitucional...',
        tribunalId: 26,
        especieId: 4,
        score: 0.599,
      );

      final searchEvent = SearchEvent(
        stage: 'search',
        status: 'success',
        timestamp: '2026-04-25T02:22:58.361Z',
        duration: 204,
        data: {},
        precedents: [precedent],
        totalFound: 10,
        averageSimilarityScore: 0.599,
      );

      fakeDataSource.setStream(Stream.value(searchEvent));

      final events = await repository.streamPipeline(1).toList();

      expect(events.length, 1);
      expect(events[0] is SearchEvent, true);
      expect((events[0] as SearchEvent).precedents.length, 1);
    });

    test(
      'streamPipeline should emit SynthesisEvent with correct classificacao',
      () async {
        final synthesisEvent = SynthesisEvent(
          stage: 'synthesis',
          status: 'success',
          timestamp: '2026-04-25T02:23:03.470Z',
          duration: 5104,
          data: {},
          id: 11,
          classificacao: 0,
          sintese_explicativa: 'A petição versa sobre...',
          precedenteId: 932,
          peticaoId: 1,
        );

        fakeDataSource.setStream(Stream.value(synthesisEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect(events[0] is SynthesisEvent, true);
        expect((events[0] as SynthesisEvent).classificacao, 0);
        expect(
          (events[0] as SynthesisEvent).sintese_explicativa,
          'A petição versa sobre...',
        );
      },
    );

    test('streamPipeline should emit CompleteEvent', () async {
      final completeEvent = CompleteEvent(
        stage: 'complete',
        status: 'success',
        timestamp: '2026-04-25T02:23:38.751Z',
        duration: 42049,
        data: {},
        totalDurationMs: 42049,
        precedentsProcessed: 10,
        synthesisGenerated: 10,
      );

      fakeDataSource.setStream(Stream.value(completeEvent));

      final events = await repository.streamPipeline(1).toList();

      expect(events.length, 1);
      expect(events[0] is CompleteEvent, true);
      expect((events[0] as CompleteEvent).precedentsProcessed, 10);
    });

    test('streamPipeline should emit ErrorEvent', () async {
      final errorEvent = ErrorEvent(
        stage: 'error',
        status: 'failed',
        timestamp: '2026-04-25T02:23:50.000Z',
        duration: 0,
        data: {},
        failedStage: 'search',
        message: 'Falha na busca vetorial',
        errorCode: 'SEARCH_ERROR',
        precedentId: null,
        recoverable: true,
      );

      fakeDataSource.setStream(Stream.value(errorEvent));

      final events = await repository.streamPipeline(1).toList();

      expect(events.length, 1);
      expect(events[0] is ErrorEvent, true);
      expect((events[0] as ErrorEvent).message, 'Falha na busca vetorial');
      expect((events[0] as ErrorEvent).recoverable, true);
    });

    test('streamPipeline should handle multiple events in sequence', () async {
      final precedent = PrecedentBackendDto(
        id: 932,
        numeroRegistro: 'tjpa-irdr-8',
        tese: 'Tese exemplo',
        tribunalId: 26,
        especieId: 4,
        score: 0.599,
      );

      final events = [
        SearchEvent(
          stage: 'search',
          status: 'success',
          timestamp: '2026-04-25T02:22:58.361Z',
          duration: 204,
          data: {},
          precedents: [precedent],
          totalFound: 10,
          averageSimilarityScore: 0.599,
        ),
        SynthesisEvent(
          stage: 'synthesis',
          status: 'success',
          timestamp: '2026-04-25T02:23:03.470Z',
          duration: 5104,
          data: {},
          id: 11,
          classificacao: 1,
          sintese_explicativa: 'Síntese...',
          precedenteId: 932,
          peticaoId: 1,
        ),
        CompleteEvent(
          stage: 'complete',
          status: 'success',
          timestamp: '2026-04-25T02:23:38.751Z',
          duration: 42049,
          data: {},
          totalDurationMs: 42049,
          precedentsProcessed: 10,
          synthesisGenerated: 10,
        ),
      ];

      fakeDataSource.setStream(Stream.fromIterable(events));

      final streamEvents = await repository.streamPipeline(1).toList();

      expect(streamEvents.length, 3);
      expect(streamEvents[0] is SearchEvent, true);
      expect(streamEvents[1] is SynthesisEvent, true);
      expect(streamEvents[2] is CompleteEvent, true);
    });

    test(
      'streamPipeline should return empty stream when data source returns empty',
      () async {
        fakeDataSource.setStream(const Stream.empty());

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 0);
        expect(events, isEmpty);
      },
    );

    test(
      'streamPipeline should pass correct peticaoId to data source',
      () async {
        final searchEvent = SearchEvent(
          stage: 'search',
          status: 'success',
          timestamp: '2026-04-25T02:22:58.361Z',
          duration: 204,
          data: {},
          precedents: [],
          totalFound: 0,
          averageSimilarityScore: 0.0,
        );

        fakeDataSource.setStream(Stream.value(searchEvent));

        await repository.streamPipeline(42).toList();

        expect(fakeDataSource.getLastPeticaoId(), 42);
      },
    );

    test('streamPipeline should pass different peticaoIds correctly', () async {
      final searchEvent = SearchEvent(
        stage: 'search',
        status: 'success',
        timestamp: '2026-04-25T02:22:58.361Z',
        duration: 204,
        data: {},
        precedents: [],
        totalFound: 0,
        averageSimilarityScore: 0.0,
      );

      fakeDataSource.setStream(Stream.value(searchEvent));
      await repository.streamPipeline(1).toList();
      expect(fakeDataSource.getLastPeticaoId(), 1);

      // Reseta stream para segunda chamada
      fakeDataSource.setStream(Stream.value(searchEvent));
      await repository.streamPipeline(999).toList();
      expect(fakeDataSource.getLastPeticaoId(), 999);
    });

    test('streamPipeline should handle error in stream', () async {
      final exception = Exception('Erro ao conectar ao servidor SSE');
      fakeDataSource.setStream(Stream.error(exception));

      expect(
        () => repository.streamPipeline(1).toList(),
        throwsA(isA<Exception>()),
      );
    });

    test('streamPipeline should handle DioException in stream', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/peticao/1/stream'),
        message: 'Connection timeout',
        type: DioExceptionType.connectionTimeout,
      );
      fakeDataSource.setStream(Stream.error(dioException));

      expect(
        () => repository.streamPipeline(1).toList(),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'streamPipeline should handle SynthesisEvent with minimal required data',
      () async {
        final synthesisEvent = SynthesisEvent(
          stage: 'synthesis',
          status: 'success',
          timestamp: '2026-04-25T02:23:03.470Z',
          duration: 5104,
          data: {},
          id: 11,
          classificacao: 2,
          sintese_explicativa: 'Síntese válida',
          precedenteId: 932,
          peticaoId: 1,
        );

        fakeDataSource.setStream(Stream.value(synthesisEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect(events[0] is SynthesisEvent, true);
        expect((events[0] as SynthesisEvent).precedenteId, 932);
        expect((events[0] as SynthesisEvent).peticaoId, 1);
      },
    );

    test(
      'streamPipeline should handle SearchEvent with empty precedents',
      () async {
        final searchEvent = SearchEvent(
          stage: 'search',
          status: 'success',
          timestamp: '2026-04-25T02:22:58.361Z',
          duration: 204,
          data: {},
          precedents: [],
          totalFound: 0,
          averageSimilarityScore: 0.0,
        );

        fakeDataSource.setStream(Stream.value(searchEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect((events[0] as SearchEvent).precedents, isEmpty);
        expect((events[0] as SearchEvent).totalFound, 0);
      },
    );

    test(
      'streamPipeline should validate all SynthesisEvent classificacao values',
      () async {
        final classificacaoValues = [0, 1, 2];

        for (final classificacao in classificacaoValues) {
          final synthesisEvent = SynthesisEvent(
            stage: 'synthesis',
            status: 'success',
            timestamp: '2026-04-25T02:23:03.470Z',
            duration: 5104,
            data: {},
            id: 11,
            classificacao: classificacao,
            sintese_explicativa: 'Síntese para classificacao $classificacao',
            precedenteId: 932,
            peticaoId: 1,
          );

          fakeDataSource.setStream(Stream.value(synthesisEvent));

          final events = await repository.streamPipeline(1).toList();

          expect(events.length, 1);
          expect((events[0] as SynthesisEvent).classificacao, classificacao);
        }
      },
    );

    test(
      'streamPipeline should preserve percentual_similaridade in event data',
      () async {
        final synthesisEvent = SynthesisEvent(
          stage: 'synthesis',
          status: 'success',
          timestamp: '2026-04-25T02:23:03.470Z',
          duration: 5104,
          data: {'percentual_similaridade': -10.5},
          id: 11,
          classificacao: 0,
          sintese_explicativa: 'Síntese com score negativo',
          precedenteId: 932,
          peticaoId: 1,
        );

        fakeDataSource.setStream(Stream.value(synthesisEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect(
          (events[0] as SynthesisEvent).data['percentual_similaridade'],
          -10.5,
        );
      },
    );

    test(
      'streamPipeline should handle very long síntese_explicativa',
      () async {
        final longSintese = 'Lorem ipsum dolor sit amet, ' * 50;

        final synthesisEvent = SynthesisEvent(
          stage: 'synthesis',
          status: 'success',
          timestamp: '2026-04-25T02:23:03.470Z',
          duration: 5104,
          data: {},
          id: 11,
          classificacao: 1,
          sintese_explicativa: longSintese,
          precedenteId: 932,
          peticaoId: 1,
        );

        fakeDataSource.setStream(Stream.value(synthesisEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect((events[0] as SynthesisEvent).sintese_explicativa, longSintese);
      },
    );

    test(
      'streamPipeline should handle error after emitting some events',
      () async {
        Stream<PipelineEvent> streamWithError() async* {
          final searchEvent = SearchEvent(
            stage: 'search',
            status: 'success',
            timestamp: '2026-04-25T02:22:58.361Z',
            duration: 204,
            data: {},
            precedents: [],
            totalFound: 10,
            averageSimilarityScore: 0.599,
          );
          yield searchEvent;
          throw Exception('Stream interrupted after SearchEvent');
        }

        fakeDataSource.setStream(streamWithError());

        expect(
          () => repository.streamPipeline(1).toList(),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('streamPipeline should handle multiple errors in sequence', () async {
      final errorEvents = [
        ErrorEvent(
          stage: 'error',
          status: 'failed',
          timestamp: '2026-04-25T02:23:50.000Z',
          duration: 0,
          data: {},
          failedStage: 'search',
          message: 'Primeiro erro',
          errorCode: 'ERROR_1',
          precedentId: null,
          recoverable: true,
        ),
        ErrorEvent(
          stage: 'error',
          status: 'failed',
          timestamp: '2026-04-25T02:23:51.000Z',
          duration: 0,
          data: {},
          failedStage: 'synthesis',
          message: 'Segundo erro',
          errorCode: 'ERROR_2',
          precedentId: null,
          recoverable: false,
        ),
      ];

      fakeDataSource.setStream(Stream.fromIterable(errorEvents));

      final events = await repository.streamPipeline(1).toList();

      expect(events.length, 2);
      expect(events[0] is ErrorEvent, true);
      expect((events[0] as ErrorEvent).message, 'Primeiro erro');
      expect((events[0] as ErrorEvent).recoverable, true);
      expect(events[1] is ErrorEvent, true);
      expect((events[1] as ErrorEvent).message, 'Segundo erro');
      expect((events[1] as ErrorEvent).recoverable, false);
    });

    test(
      'streamPipeline should handle CompleteEvent with zero values',
      () async {
        final completeEvent = CompleteEvent(
          stage: 'complete',
          status: 'success',
          timestamp: '2026-04-25T02:23:38.751Z',
          duration: 0,
          data: {},
          totalDurationMs: 0,
          precedentsProcessed: 0,
          synthesisGenerated: 0,
        );

        fakeDataSource.setStream(Stream.value(completeEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect(events[0] is CompleteEvent, true);
        expect((events[0] as CompleteEvent).totalDurationMs, 0);
        expect((events[0] as CompleteEvent).precedentsProcessed, 0);
        expect((events[0] as CompleteEvent).synthesisGenerated, 0);
      },
    );

    test(
      'streamPipeline should handle ErrorEvent with recoverable false',
      () async {
        final errorEvent = ErrorEvent(
          stage: 'error',
          status: 'failed',
          timestamp: '2026-04-25T02:23:50.000Z',
          duration: 0,
          data: {},
          failedStage: 'search',
          message: 'Erro não recuperável',
          errorCode: 'FATAL_ERROR',
          precedentId: null,
          recoverable: false,
        );

        fakeDataSource.setStream(Stream.value(errorEvent));

        final events = await repository.streamPipeline(1).toList();

        expect(events.length, 1);
        expect(events[0] is ErrorEvent, true);
        expect((events[0] as ErrorEvent).recoverable, false);
      },
    );

    test('streamPipeline should handle peticaoId zero', () async {
      final searchEvent = SearchEvent(
        stage: 'search',
        status: 'success',
        timestamp: '2026-04-25T02:22:58.361Z',
        duration: 204,
        data: {},
        precedents: [],
        totalFound: 0,
        averageSimilarityScore: 0.0,
      );

      fakeDataSource.setStream(Stream.value(searchEvent));
      await repository.streamPipeline(0).toList();

      expect(fakeDataSource.getLastPeticaoId(), 0);
    });

    test('streamPipeline should handle negative peticaoId', () async {
      final searchEvent = SearchEvent(
        stage: 'search',
        status: 'success',
        timestamp: '2026-04-25T02:22:58.361Z',
        duration: 204,
        data: {},
        precedents: [],
        totalFound: 0,
        averageSimilarityScore: 0.0,
      );

      fakeDataSource.setStream(Stream.value(searchEvent));
      await repository.streamPipeline(-1).toList();

      expect(fakeDataSource.getLastPeticaoId(), -1);
    });
  });
}
