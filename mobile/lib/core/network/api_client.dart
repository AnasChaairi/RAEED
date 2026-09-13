import 'package:dio/dio.dart';

import '../config/app_environment.dart';
import '../error/api_error_code.dart';
import '../error/raeed_exception.dart';
import 'api_envelope.dart';

/// The app's one HTTP entry point.
///
/// Wraps `dio` so that no other layer imports it: every caller sees plain JSON
/// maps in and [RaeedException] subtypes out. That keeps the HTTP client a
/// data-layer implementation detail — swapping it would not touch a single
/// repository, use case, or widget.
///
/// It deliberately does **not** re-implement any business rule. Per
/// `specs/README.md`, the backend is the single source of truth; this class
/// transports requests and translates failures, nothing more.
class ApiClient {
  ApiClient({required AppEnvironment environment, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: environment.apiBaseUrl,
      connectTimeout: environment.connectTimeout,
      receiveTimeout: environment.receiveTimeout,
      sendTimeout: environment.connectTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // Never let dio throw on a non-2xx: the envelope carries the error code
      // and is parsed uniformly below, so a 403 and a 422 travel the same path.
      validateStatus: (_) => true,
    );
  }

  final Dio _dio;

  /// The underlying client, exposed only so interceptors can be attached
  /// during composition. Nothing outside `core/network` should call it.
  Dio get raw => _dio;

  /// GETs a single resource, returned unwrapped per the envelope convention.
  Future<Map<String, Object?>> getObject(
    String path, {
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) async {
    final response = await _send(
      () => _dio.get<Object?>(
        path,
        queryParameters: _clean(query),
        cancelToken: cancelToken,
      ),
    );
    return asJsonObject(response, context: 'GET $path');
  }

  /// GETs a list endpoint and decodes its `{ data, page }` envelope.
  Future<Paginated<T>> getList<T>(
    String path,
    T Function(Map<String, Object?> json) itemFromJson, {
    Map<String, Object?>? query,
    String? cursor,
    CancelToken? cancelToken,
  }) async {
    final response = await _send(
      () => _dio.get<Object?>(
        path,
        queryParameters: _clean({...?query, 'cursor': cursor}),
        cancelToken: cancelToken,
      ),
    );
    return Paginated.fromJson<T>(response, itemFromJson);
  }

  /// POSTs a body and returns the decoded response object.
  ///
  /// A `204`/empty body decodes to an empty map rather than throwing — several
  /// endpoints in the contract answer `202`/`204` with no content.
  Future<Map<String, Object?>> post(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) async {
    final response = await _send(
      () => _dio.post<Object?>(
        path,
        data: body,
        queryParameters: _clean(query),
        cancelToken: cancelToken,
      ),
    );
    return response == null
        ? const <String, Object?>{}
        : asJsonObject(response, context: 'POST $path');
  }

  /// PATCHes a resource and returns the decoded response object.
  Future<Map<String, Object?>> patch(
    String path, {
    Object? body,
    CancelToken? cancelToken,
  }) async {
    final response = await _send(
      () => _dio.patch<Object?>(path, data: body, cancelToken: cancelToken),
    );
    return response == null
        ? const <String, Object?>{}
        : asJsonObject(response, context: 'PATCH $path');
  }

  /// DELETEs a resource. Returns normally on any 2xx, including `204`.
  Future<void> delete(String path, {CancelToken? cancelToken}) async {
    await _send(() => _dio.delete<Object?>(path, cancelToken: cancelToken));
  }

  /// Runs a request and normalises every outcome into either a decoded body or
  /// a [RaeedException].
  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    final Response<Object?> response;
    try {
      response = await request();
    } on DioException catch (error, stackTrace) {
      throw _fromDioException(error, stackTrace);
    }

    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return response.data;
    throw _fromErrorEnvelope(response);
  }

  /// Translates a transport-level dio failure.
  ///
  /// Timeouts and connection errors become [NetworkException] specifically so
  /// callers can distinguish "we are offline, queue this and degrade to cache"
  /// from "the server rejected this".
  RaeedException _fromDioException(DioException error, StackTrace stackTrace) =>
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout => NetworkException(
          message: 'The request timed out.',
          cause: error,
          stackTrace: stackTrace,
        ),
        DioExceptionType.connectionError ||
        DioExceptionType.badCertificate => NetworkException(
          message: 'Could not reach the RAEED server.',
          cause: error,
          stackTrace: stackTrace,
        ),
        DioExceptionType.cancel => NetworkException(
          message: 'The request was cancelled.',
          cause: error,
          stackTrace: stackTrace,
        ),
        DioExceptionType.badResponse ||
        DioExceptionType.unknown => NetworkException(
          message: error.message ?? 'The request failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      };

  /// Parses the uniform error envelope every failure carries.
  ///
  /// A `401` becomes [UnauthenticatedException] so the session layer can end
  /// the session, except for `auth.otp_invalid`, which is a normal, expected
  /// outcome of the login form and must stay on the OTP screen.
  RaeedException _fromErrorEnvelope(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;

    var code = ApiErrorCode.unknown;
    var message = 'The request failed (HTTP $status).';
    var details = const <String, Object?>{};

    if (body is Map) {
      final error = body['error'];
      if (error is Map) {
        code = ApiErrorCode.fromWire(error['code'] as String?);
        message = error['message'] as String? ?? message;
        final rawDetails = error['details'];
        if (rawDetails is Map) details = rawDetails.cast<String, Object?>();
      }
    }

    if (status == 401 && code != ApiErrorCode.authOtpInvalid) {
      return UnauthenticatedException(message: message);
    }

    return ApiException(
      code: code,
      message: message,
      statusCode: status,
      details: details,
    );
  }

  /// Drops null-valued query parameters so they are not serialised as the
  /// literal string "null".
  Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    final cleaned = <String, Object?>{
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    return cleaned.isEmpty ? null : cleaned;
  }
}
