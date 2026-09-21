/// Tolerant readers shared by the executive decoders.
///
/// Several of the executive endpoints are proposed rather than contracted
/// (see the repository interfaces), so the decoders accept a couple of
/// plausible spellings for the same field instead of insisting on one. The
/// helpers in `core/network/api_envelope.dart` remain the tool for fields the
/// contract does fix — an id, a timestamp — where failing loudly is right.
library;

import '../../../core/error/raeed_exception.dart';

Map<String, Object?>? objectOrNull(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  return null;
}

List<Map<String, Object?>> objectList(Object? value, {required String field}) {
  if (value == null) return const [];
  if (value is! List) {
    throw ContractException(message: 'Field `$field` should be an array');
  }
  return [
    for (final element in value)
      objectOrNull(element) ??
          (throw ContractException(
            message: 'Field `$field` should contain objects',
          )),
  ];
}

String? stringOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// The first non-null string among [keys] in [json].
String? firstString(Map<String, Object?> json, List<String> keys) {
  for (final key in keys) {
    final value = stringOrNull(json[key]);
    if (value != null) return value;
  }
  return null;
}

int? intOrNull(Object? value) => switch (value) {
  int() => value,
  double() => value.round(),
  String() => int.tryParse(value),
  _ => null,
};

double? doubleOrNull(Object? value) => switch (value) {
  num() => value.toDouble(),
  String() => double.tryParse(value),
  _ => null,
};

bool boolOr(Object? value, bool fallback) => value is bool ? value : fallback;

DateTime? dateOrNull(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;

List<String> stringList(Object? value) => value is List
    ? [
        for (final element in value)
          if (stringOrNull(element) case final String text) text,
      ]
    : const [];
