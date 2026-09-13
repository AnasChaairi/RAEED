import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// Points `package:sqlite3` at a SQLite library that actually exists on the
/// host running the tests.
///
/// The app itself never needs this: on a device, `sqlite3_flutter_libs` bundles
/// SQLite into the APK/IPA. But a `flutter test` runs on the Dart VM against
/// the host's own library, and drift's default resolver asks for the
/// unversioned `libsqlite3.so`, which is part of the *development* package.
/// Plenty of Linux machines and CI images ship only the runtime `libsqlite3.so.0`,
/// so the default resolver fails with "cannot open shared object file" on a
/// system that has a perfectly good SQLite.
///
/// Rather than make every developer install a -dev package to run the test
/// suite, this tries the usual names in order. Call it from `setUpAll` in any
/// test that opens a database.
void configureSqliteForTests() {
  if (_configured) return;
  _configured = true;

  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
  } else if (Platform.isMacOS) {
    open.overrideFor(OperatingSystem.macOS, _openOnMacOS);
  }
}

bool _configured = false;

DynamicLibrary _openOnLinux() => _firstThatOpens(const [
  'libsqlite3.so',
  'libsqlite3.so.0',
  '/usr/lib64/libsqlite3.so.0',
  '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
]);

DynamicLibrary _openOnMacOS() =>
    _firstThatOpens(const ['libsqlite3.dylib', '/usr/lib/libsqlite3.dylib']);

/// Opens the first candidate that loads, or reports every name it tried.
///
/// A bare "cannot open shared object file" sends people hunting; naming the
/// candidates and the fix does not.
DynamicLibrary _firstThatOpens(List<String> candidates) {
  for (final candidate in candidates) {
    try {
      return DynamicLibrary.open(candidate);
    } on ArgumentError {
      continue;
    }
  }
  throw StateError(
    'No SQLite library found. Tried: ${candidates.join(', ')}.\n'
    'Install SQLite for your platform — on Debian/Ubuntu, '
    '`apt-get install libsqlite3-0`; on Fedora, `dnf install sqlite-libs`.',
  );
}
