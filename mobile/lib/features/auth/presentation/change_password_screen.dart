import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../domain/password_policy.dart';
import 'auth_providers.dart';
import 'login_screen.dart';

/// Change the signed-in user's password (`/more/password`).
///
/// Loading: none — the form is local until submit. Empty: n/a. Error: a wrong
/// current password is shown under that field and the form stays; anything
/// else is a snackbar. Success: a toast, and back to More.
///
/// The current password is asked for even though the user is signed in: a
/// phone left unlocked on a table must not be enough to lock its owner out.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _showValidation = false;
  bool _saving = false;
  bool _reveal = false;

  /// Set when the server refused the current password; cleared on edit.
  bool _currentRefused = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [_current, _next, _confirm]) {
      controller.addListener(_onEdited);
    }
  }

  @override
  void dispose() {
    for (final controller in [_current, _next, _confirm]) {
      controller
        ..removeListener(_onEdited)
        ..dispose();
    }
    super.dispose();
  }

  void _onEdited() {
    if (_currentRefused || _showValidation) {
      setState(() {
        _currentRefused = false;
        _showValidation = false;
      });
    }
  }

  bool get _isValid =>
      PasswordPolicy.isWellFormed(_current.text) &&
      PasswordPolicy.isWellFormed(_next.text) &&
      _next.text == _confirm.text;

  String? _ruleError(String value) =>
      _showValidation && !PasswordPolicy.isWellFormed(value)
      ? AppL10n.of(context).loginPasswordInvalid
      : null;

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _showValidation = true);
      return;
    }
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(changePasswordProvider)(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.pwdSavedToast)));
      navigator.pop();
    } catch (error) {
      if (!mounted) return;
      final failure = presentFailure(error, l10n);
      if (failure.isWrongCredentials) {
        setState(() => _currentRefused = true);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(failure.body)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(title: Text(l10n.pwdTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RaeedSpacing.lg),
          children: [
            Text(
              l10n.pwdIntro,
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
            ),
            const SizedBox(height: RaeedSpacing.xl),
            _PasswordField(
              key: const Key('pwd-current'),
              controller: _current,
              label: l10n.pwdCurrent,
              reveal: _reveal,
              enabled: !_saving,
              errorText: _currentRefused
                  ? l10n.pwdWrongCurrent
                  : _ruleError(_current.text),
              action: TextInputAction.next,
            ),
            const SizedBox(height: RaeedSpacing.lg),
            _PasswordField(
              key: const Key('pwd-new'),
              controller: _next,
              label: l10n.pwdNew,
              helperText: l10n.loginPasswordRule,
              reveal: _reveal,
              enabled: !_saving,
              errorText: _ruleError(_next.text),
              action: TextInputAction.next,
            ),
            const SizedBox(height: RaeedSpacing.lg),
            _PasswordField(
              key: const Key('pwd-confirm'),
              controller: _confirm,
              label: l10n.pwdConfirm,
              reveal: _reveal,
              enabled: !_saving,
              errorText: _showValidation && _next.text != _confirm.text
                  ? l10n.pwdMismatch
                  : null,
              action: TextInputAction.done,
              onSubmitted: _saving ? null : _submit,
            ),
            const SizedBox(height: RaeedSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _reveal = !_reveal),
                icon: Icon(
                  _reveal
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                label: Text(
                  _reveal ? l10n.loginPasswordHide : l10n.loginPasswordShow,
                ),
              ),
            ),
            const SizedBox(height: RaeedSpacing.xl),
            FilledButton(
              key: const Key('pwd-submit'),
              onPressed: _saving ? null : _submit,
              child: _saving ? const AuthButtonSpinner() : Text(l10n.pwdSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.reveal,
    required this.enabled,
    required this.action,
    this.helperText,
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final String? errorText;
  final bool reveal;
  final bool enabled;
  final TextInputAction action;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: !reveal,
    enabled: enabled,
    keyboardType: TextInputType.visiblePassword,
    textInputAction: action,
    onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    textDirection: TextDirection.ltr,
    textAlign: context.isRtl ? TextAlign.end : TextAlign.start,
    autocorrect: false,
    enableSuggestions: false,
    inputFormatters: [LengthLimitingTextInputFormatter(PasswordPolicy.length)],
    style: context.type.body.copyWith(color: context.palette.ink),
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      errorText: errorText,
    ),
  );
}
