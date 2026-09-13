import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/config/app_environment.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/network/api_client.dart';
import 'package:raeed/features/children/data/children_repository_api.dart';
import 'package:raeed/features/children/domain/child_age.dart';
import 'package:raeed/features/children/domain/child_day_status.dart';

void main() {
  late _StubAdapter adapter;
  late ApiChildrenRepository repository;

  setUp(() {
    adapter = _StubAdapter();
    repository = ApiChildrenRepository(
      ApiClient(
        environment: const AppEnvironment(
          flavor: AppFlavor.dev,
          apiBaseUrl: 'http://localhost:3000/api/v1',
          sentryDsn: '',
          connectTimeout: Duration(seconds: 1),
          receiveTimeout: Duration(seconds: 1),
        ),
        dio: Dio()..httpClientAdapter = adapter,
      ),
    );
  });

  group('fetchChildren', () {
    test('decodes the list envelope and its cursor', () async {
      adapter.respond(200, {
        'data': [
          {
            'id': 'child-1',
            'full_name': 'آدم',
            'health_alert': false,
            'group': {'id': 'group-1', 'name': 'الأشبال'},
          },
        ],
        'page': {'cursor': 'abc', 'has_more': true},
      });

      final page = await repository.fetchChildren();

      expect(page.items.single.id, 'child-1');
      expect(page.items.single.fullName, 'آدم');
      expect(page.items.single.group!.name, 'الأشبال');
      expect(page.page.cursor, 'abc');
      expect(page.page.hasMore, isTrue);
    });

    test(
      'passes the cursor and group filter through as query params',
      () async {
        adapter.respond(200, {'data': <Object?>[]});

        await repository.fetchChildren(cursor: 'abc', groupId: 'group-9');

        expect(adapter.lastRequest!.queryParameters['cursor'], 'abc');
        expect(adapter.lastRequest!.queryParameters['group_id'], 'group-9');
      },
    );

    test('tolerates a child with no group — a season boundary is a real '
        'state, not a bad payload', () async {
      adapter.respond(200, {
        'data': [
          {'id': 'child-1', 'full_name': 'آدم', 'health_alert': false},
        ],
      });

      final page = await repository.fetchChildren();

      expect(page.items.single.group, isNull);
    });

    test(
      'an unrecognised status decodes to unknown, not an exception',
      () async {
        // A new attendance_status shipped by the backend must not take down a
        // parent's home screen.
        adapter.respond(200, {
          'data': [
            {
              'id': 'child-1',
              'full_name': 'آدم',
              'health_alert': false,
              'today_status': {'kind': 'teleported'},
            },
          ],
        });

        final page = await repository.fetchChildren();

        expect(page.items.single.todayStatus.kind, DayStatusKind.unknown);
      },
    );

    test(
      'a malformed payload fails loudly rather than reading as empty',
      () async {
        // An empty attendance list looks exactly like "nobody is enrolled",
        // which on this product is a safeguarding failure.
        adapter.respond(200, {'data': 'not-an-array'});

        await expectLater(
          repository.fetchChildren(),
          throwsA(isA<ContractException>()),
        );
      },
    );

    test('a child missing its required id fails loudly', () async {
      adapter.respond(200, {
        'data': [
          {'full_name': 'آدم', 'health_alert': false},
        ],
      });

      await expectLater(
        repository.fetchChildren(),
        throwsA(isA<ContractException>()),
      );
    });

    test('scope.forbidden surfaces as a terminal ApiException', () async {
      adapter.respond(403, {
        'error': {'code': 'scope.forbidden', 'message': 'Outside your scope.'},
      });

      await expectLater(
        repository.fetchChildren(),
        throwsA(
          isA<ApiException>().having((e) => e.isScopeFailure, 'scope', isTrue),
        ),
      );
    });

    test('a connection failure surfaces as NetworkException', () async {
      adapter.throwDio(DioExceptionType.connectionError);

      await expectLater(
        repository.fetchChildren(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('fetchChild', () {
    test('decodes the detail payload including health info', () async {
      adapter.respond(200, {
        'id': 'child-1',
        'full_name': 'آدم',
        'health_alert': true,
        'image_rights_level': 'app_only',
        'health_json': {
          'allergies': ['الفول السوداني'],
        },
      });

      final detail = await repository.fetchChild('child-1');

      expect(detail.id, 'child-1');
      expect(detail.health.allergies, ['الفول السوداني']);
    });

    test('an unrecognised image-rights level falls back to the most '
        'restrictive', () async {
      // A level this build does not know must never widen what may be
      // published.
      adapter.respond(200, {
        'id': 'child-1',
        'full_name': 'آدم',
        'health_alert': false,
        'image_rights_level': 'some_future_level',
      });

      final detail = await repository.fetchChild('child-1');

      expect(detail.imageRightsLevel.wireValue, 'not_allowed');
    });
  });

  group('ageInYearsOn', () {
    test('counts completed years', () {
      expect(ageInYearsOn(DateTime(2018, 5, 2), DateTime(2026, 5, 2)), 8);
    });

    test('does not count a birthday that has not happened yet', () {
      expect(ageInYearsOn(DateTime(2018, 5, 2), DateTime(2026, 5)), 7);
    });

    test('handles a 29 February birthday in a non-leap year', () {
      expect(ageInYearsOn(DateTime(2016, 2, 29), DateTime(2026, 2, 28)), 9);
      expect(ageInYearsOn(DateTime(2016, 2, 29), DateTime(2026, 3)), 10);
    });

    test(
      'returns null for a date in the future rather than a negative age',
      () {
        expect(ageInYearsOn(DateTime(2030), DateTime(2026)), isNull);
      },
    );
  });
}

class _StubAdapter implements HttpClientAdapter {
  int _status = 200;
  Object? _body;
  DioExceptionType? _throwType;

  RequestOptions? lastRequest;

  void respond(int status, Object? body) {
    _status = status;
    _body = body;
    _throwType = null;
  }

  void throwDio(DioExceptionType type) => _throwType = type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final throwType = _throwType;
    if (throwType != null) {
      throw DioException(requestOptions: options, type: throwType);
    }
    return ResponseBody.fromString(
      _body == null ? '' : jsonEncode(_body),
      _status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
