import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// Which brightness the app renders in.
///
/// Follows the system by default. The More screen offers an explicit dark
/// toggle for the executive who reads the dashboard in a dim hall and wants
/// it dark regardless of what the phone thinks — a *presentation* choice
/// that never touches the palette itself, which stays the generated tokens
/// for whichever brightness is active.
///
/// In memory only for now: persisting it is a small follow-up once a
/// preferences store exists, and a toggle that resets on restart is a
/// nuisance, not a safeguarding risk.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  void setDark(bool dark) => state = dark ? ThemeMode.dark : ThemeMode.light;

  void followSystem() => state = ThemeMode.system;
}
