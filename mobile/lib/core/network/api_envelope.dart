/// Decoders for the response envelope in `specs/04-api/conventions.md`.
///
/// Two shapes exist and only two:
///
/// * a list endpoint returns `{ "data": [...], "page": { cursor, has_more } }`
/// * a single resource returns the resource object directly, unwrapped
///
/// Everything below fails loudly with a [ContractException] when a payload
/// does not match, rather than coercing it. A silently-empty list on a
/// malformed attendance sheet would look exactly like "nobody is enrolled",
/// which on this product is a safeguarding failure, not a cosmetic bug.
library;

import '../error/raeed_exception.dart';

/// Cursor-based pagination state.
///
/// Offset pagination is deliberately absent: it breaks under concurrent writes
/// on live lists like attendance and messages.
class PageInfo {
  const PageInfo({required this.cursor, required this.hasMore});

  /// An exhausted page — no cursor, nothing more to fetch.
  const PageInfo.end() : cursor = null, hasMore = false;

  /// Parses the `page` object, tolerating its absence (a single-page response
  /// may omit it entirely).
  factory PageInfo.fromJson(Map<String, Object?>? json) {
    if (json == null) return const PageInfo.end();
    final cursor = json['cursor'];
    if (cursor != null && cursor is! String) {
      throw const ContractException(
        message: 'page.cursor must be a string or null',
      );
    }
    return PageInfo(
      cursor: cursor as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  /// Opaque cursor to pass as `?cursor=` on the next request.
  final String? cursor;

  /// Whether another page exists.
  final bool hasMore;

  /// Whether a follow-up request can be made.
  bool get canLoadMore => hasMore && cursor != null;
}

/// One page of a list endpoint's results.
class Paginated<T> {
  const Paginated({required this.items, required this.page});

  /// An empty page, used as the initial state of a paged list.
  const Paginated.empty() : items = const [], page = const PageInfo.end();

  /// The decoded `data` array.
  final List<T> items;

  /// Pagination state for fetching the next page.
  final PageInfo page;

  /// Decodes `{ data: [...], page: {...} }`, mapping each element with
  /// [itemFromJson].
  ///
  /// Throws a [ContractException] when `data` is missing or is not an array —
  /// the contract in `specs/04-api/openapi.yaml` always provides it.
  static Paginated<T> fromJson<T>(
    Object? body,
    T Function(Map<String, Object?> json) itemFromJson,
  ) {
    if (body is! Map<String, Object?>) {
      throw ContractException(
        message: 'Expected a list envelope object, got ${body.runtimeType}',
      );
    }
    final data = body['data'];
    if (data is! List) {
      throw const ContractException(
        message: 'List envelope is missing its `data` array',
      );
    }
    return Paginated<T>(
      items: data
          .map(
            (element) => itemFromJson(asJsonObject(element, context: 'data[]')),
          )
          .toList(growable: false),
      page: PageInfo.fromJson(body['page'] as Map<String, Object?>?),
    );
  }

  /// Returns this page followed by [next], carrying [next]'s cursor forward.
  ///
  /// Used to accumulate an infinite list without re-fetching earlier pages.
  Paginated<T> append(Paginated<T> next) =>
      Paginated<T>(items: [...items, ...next.items], page: next.page);
}

/// Casts a decoded JSON value to an object, with a contract error naming
/// [context] when it is not one.
Map<String, Object?> asJsonObject(Object? value, {required String context}) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  throw ContractException(
    message: 'Expected a JSON object at $context, got ${value.runtimeType}',
  );
}

/// Reads a required field, failing with a contract error rather than returning
/// null and letting it surface as a confusing error three layers up.
T requireField<T>(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is T) return value;
  throw ContractException(
    message: value == null
        ? 'Required field `$key` was missing'
        : 'Field `$key` should be $T but was ${value.runtimeType}',
  );
}

/// Parses a required ISO-8601 timestamp field.
DateTime requireDateTime(Map<String, Object?> json, String key) {
  final raw = requireField<String>(json, key);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw ContractException(message: 'Field `$key` is not a valid date: $raw');
  }
  return parsed.toUtc();
}

/// Parses an optional ISO-8601 timestamp field.
DateTime? optionalDateTime(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw == null) return null;
  if (raw is! String) {
    throw ContractException(message: 'Field `$key` should be a date string');
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw ContractException(message: 'Field `$key` is not a valid date: $raw');
  }
  return parsed.toUtc();
}

/// Resolves a wire string onto an enum, falling back to [fallback] when the
/// server sends a value this build predates.
///
/// A new `attendance_status` must not crash an older app; it renders as the
/// fallback until the app is updated.
T enumFromWire<T>(
  Object? value,
  Map<String, T> byWireValue, {
  required T fallback,
}) => value is String ? byWireValue[value] ?? fallback : fallback;
