import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/app_session.dart';
import '../session/session_controller.dart';

part 'locale_controller.g.dart';

/// The locales RAEED ships.
///
/// Arabic first, and not merely first in the list: it is the default for a
/// signed-out user regardless of device settings. RAEED Academy's families
/// read Arabic; defaulting to a French phone's system locale would hand a
/// parent an interface in the wrong language on the login screen, before the
/// app knows anything about them.
const List<Locale> supportedLocales = [
  Locale('ar'),
  Locale('fr'),
  Locale('en'),
];

/// The default locale before a user preference is known.
const Locale defaultLocale = Locale('ar');

/// Resolves which locale the UI runs in.
///
/// Precedence: an explicit in-app choice, then the signed-in user's
/// `app_user.preferred_locale`, then Arabic. The device locale is deliberately
/// not consulted — see [supportedLocales].
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  Locale? _override;

  @override
  Locale build() {
    final preferred = ref.watch(
      sessionControllerProvider.select(
        (AppSession session) => session.user?.preferredLocale,
      ),
    );
    return _override ?? _resolve(preferred);
  }

  /// Sets an explicit in-app language choice.
  void setLocale(Locale locale) {
    if (!supportedLocales.any((s) => s.languageCode == locale.languageCode)) {
      return;
    }
    _override = locale;
    ref.invalidateSelf();
  }

  /// Clears the in-app choice, falling back to the account preference.
  void clearOverride() {
    _override = null;
    ref.invalidateSelf();
  }

  Locale _resolve(String? languageCode) {
    if (languageCode == null) return defaultLocale;
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return defaultLocale;
  }
}
