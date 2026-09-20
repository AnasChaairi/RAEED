import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:raeed/core/config/app_environment.dart';
import 'package:raeed/core/network/api_client.dart';

/// An [HttpClientAdapter] that answers every request with a canned body.
class StubAdapter implements HttpClientAdapter {
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

  /// The JSON body of the last request, decoded.
  Map<String, Object?> get lastBody =>
      (lastRequest!.data as Map).cast<String, Object?>();

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

/// An [ApiClient] wired to [adapter].
ApiClient stubClient(StubAdapter adapter) => ApiClient(
  environment: const AppEnvironment(
    flavor: AppFlavor.dev,
    apiBaseUrl: 'http://localhost:3000/api/v1',
    sentryDsn: '',
    connectTimeout: Duration(seconds: 1),
    receiveTimeout: Duration(seconds: 1),
  ),
  dio: Dio()..httpClientAdapter = adapter,
);
