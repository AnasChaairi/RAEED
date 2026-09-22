import '../error/raeed_exception.dart';

/// The retry policy for every async provider in the app.
///
/// Riverpod would otherwise retry any failed provider with exponential
/// backoff, which is right for a dropped connection and wrong for a refusal:
/// a `scope.forbidden` answer is terminal (see [ApiException.isScopeFailure]),
/// and every repeated attempt would be recorded by the server as another
/// `access.denied` entry in the executive's name. Client errors in general
/// (4xx) will not change on their own, so they are not retried either.
Duration? raeedProviderRetry(int retryCount, Object error) {
  if (error is ApiException) {
    final status = error.statusCode;
    if (error.isScopeFailure || (status != null && status < 500)) return null;
  }
  if (retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (1 << retryCount));
}
