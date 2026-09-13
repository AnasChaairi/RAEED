import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/config/app_environment.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/network/api_client.dart';

/// The client is the one place every API failure is classified, so the
/// classification is tested directly rather than inferred from a screen.
void main() {
  late _StubAdapter adapter;
  late ApiClient client;

  setUp(() {
    adapter = _StubAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    client = ApiClient(
      environment: const AppEnvironment(
        flavor: AppFlavor.dev,
        apiBaseUrl: 'http://localhost:3000/api/v1',
        sentryDsn: '',
        connectTimeout: Duration(seconds: 1),
        receiveTimeout: Duration(seconds: 1),
      ),
      dio: dio,
    );
  });

  group('success envelopes', () {
    test('a single resource is returned unwrapped', () async {
      adapter.respondJson(200, {'id': 'child-1', 'full_name': 'آدم'});

      final result = await client.getObject('/children/child-1');

      expect(result['id'], 'child-1');
      expect(result['full_name'], 'آدم');
    });

    test('a list endpoint decodes data and page', () async {
      adapter.respondJson(200, {
        'data': [
          {'id': 'child-1'},
          {'id': 'child-2'},
        ],
        'page': {'cursor': 'eyJpZCI6', 'has_more': true},
      });

      final result = await client.getList<String>(
        '/children',
        (json) => json['id']! as String,
      );

      expect(result.items, ['child-1', 'child-2']);
      expect(result.page.cursor, 'eyJpZCI6');
      expect(result.page.hasMore, isTrue);
      expect(result.page.canLoadMore, isTrue);
    });

    test('a list with no page object is treated as a final page', () async {
      adapter.respondJson(200, {
        'data': [
          {'id': 'child-1'},
        ],
      });

      final result = await client.getList<String>(
        '/children',
        (json) => json['id']! as String,
      );

      expect(result.page.hasMore, isFalse);
      expect(result.page.canLoadMore, isFalse);
    });

    test('an empty 204 body decodes to an empty map, not an error', () async {
      adapter.respond(204, null);
      expect(await client.post('/sessions/s-1/presence-confirmation'), isEmpty);
    });

    test('null query parameters are dropped, not sent as "null"', () async {
      adapter.respondJson(200, {'data': <Object?>[]});

      await client.getList<String>(
        '/children',
        (json) => json['id']! as String,
        query: {'group_id': null, 'season_id': 'season-1'},
      );

      expect(adapter.lastRequest!.queryParameters, {'season_id': 'season-1'});
    });
  });

  group('error envelopes', () {
    test('403 scope.forbidden becomes a terminal ApiException', () async {
      adapter.respondJson(403, {
        'error': {'code': 'scope.forbidden', 'message': 'Outside your scope.'},
      });

      final error = await _captureError(() => client.getObject('/children/x'));

      expect(error, isA<ApiException>());
      final api = error! as ApiException;
      expect(api.code, ApiErrorCode.scopeForbidden);
      expect(api.statusCode, 403);
      expect(
        api.isScopeFailure,
        isTrue,
        reason: 'the UI must render this as final, with no retry',
      );
    });

    test('409 attendance.conflict carries its code and details', () async {
      // The offline-sync conflict from specs/11-testing-strategy.md, case 1:
      // the loser must be told, never silently overwritten.
      adapter.respondJson(409, {
        'error': {
          'code': 'attendance.conflict',
          'message': 'Already recorded.',
          'details': {'child_id': 'child-1'},
        },
      });

      final error = await _captureError(
        () => client.patch('/sessions/s-1/attendance'),
      );

      expect(error, isA<ApiException>());
      final api = error! as ApiException;
      expect(api.code, ApiErrorCode.attendanceConflict);
      expect(api.details['child_id'], 'child-1');
    });

    test('422 memories.consent_blocked names the offending child', () async {
      adapter.respondJson(422, {
        'error': {
          'code': 'memories.consent_blocked',
          'message': 'Consent missing.',
          'details': {'child_id': 'child-9'},
        },
      });

      final error = await _captureError(() => client.post('/memories/posts'));

      expect(
        (error! as ApiException).code,
        ApiErrorCode.memoriesConsentBlocked,
      );
      expect((error as ApiException).details['child_id'], 'child-9');
    });

    test('401 ends the session', () async {
      adapter.respondJson(401, {
        'error': {'code': 'auth.expired', 'message': 'Expired.'},
      });

      expect(
        await _captureError(() => client.getObject('/children')),
        isA<UnauthenticatedException>(),
      );
    });

    test('401 auth.otp_invalid does NOT end the session', () async {
      // A wrong OTP is an expected outcome of the login form. Treating it as a
      // session expiry would bounce the user off the screen they are using.
      adapter.respondJson(401, {
        'error': {'code': 'auth.otp_invalid', 'message': 'Wrong code.'},
      });

      final error = await _captureError(
        () => client.post('/auth/otp/verify', body: {'code': '000000'}),
      );

      expect(error, isA<ApiException>());
      expect((error! as ApiException).code, ApiErrorCode.authOtpInvalid);
    });

    test('an unknown code degrades instead of crashing an older build', () async {
      // The backend may ship a new code before the mobile release that knows
      // about it; specs/04-api/conventions.md makes the mobile cadence set the
      // deprecation window.
      adapter.respondJson(422, {
        'error': {'code': 'homework.some_future_rule', 'message': 'Nope.'},
      });

      final error = await _captureError(() => client.post('/homework'));

      expect((error! as ApiException).code, ApiErrorCode.unknown);
      expect((error as ApiException).statusCode, 422);
    });

    test('an error response with no envelope still classifies', () async {
      adapter.respond(500, 'Internal Server Error');

      final error = await _captureError(() => client.getObject('/children'));

      expect(error, isA<ApiException>());
      expect((error! as ApiException).code, ApiErrorCode.unknown);
    });
  });

  group('transport failures', () {
    test('a connection error is a NetworkException, not an ApiException', () async {
      // The distinction drives real behaviour: offline means queue and degrade
      // to cache, a server error means show a failure.
      adapter.throwDio(DioExceptionType.connectionError);

      expect(
        await _captureError(() => client.getObject('/children')),
        isA<NetworkException>(),
      );
    });

    test('a timeout is a NetworkException', () async {
      adapter.throwDio(DioExceptionType.receiveTimeout);

      expect(
        await _captureError(() => client.getObject('/children')),
        isA<NetworkException>(),
      );
    });

    test('no DioException escapes the data layer', () async {
      for (final type in DioExceptionType.values) {
        adapter.throwDio(type);
        final error = await _captureError(() => client.getObject('/children'));
        expect(
          error,
          isA<RaeedException>(),
          reason: '$type must be translated, not leaked',
        );
      }
    });
  });

  group('contract violations', () {
    test('a list response whose data is not an array fails loudly', () async {
      // Silently yielding an empty list here would look exactly like "nobody is
      // enrolled in this group", which on an attendance sheet is a
      // safeguarding failure rather than a cosmetic bug.
      adapter.respondJson(200, {'data': 'not-an-array'});

      expect(
        await _captureError(
          () => client.getList<String>('/children', (json) => 'x'),
        ),
        isA<ContractException>(),
      );
    });

    test(
      'a single-resource response that is not an object fails loudly',
      () async {
        adapter.respondJson(200, ['unexpected']);

        expect(
          await _captureError(() => client.getObject('/children/child-1')),
          isA<ContractException>(),
        );
      },
    );
  });
}

/// Runs [action] and returns whatever it threw, or null if it did not throw.
Future<Object?> _captureError(Future<Object?> Function() action) async {
  try {
    await action();
    return null;
  } on Object catch (error) {
    return error;
  }
}

/// A dio adapter that returns canned responses.
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

  void respondJson(int status, Object body) => respond(status, body);

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
