import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../domain/otp_policy.dart';
import 'auth_providers.dart';
import 'auth_scaffold.dart';
import 'login_screen.dart' show AuthButtonSpinner;
import 'widgets/otp_boxes.dart';

/// Verifies the one-time code (`RAEED-2`).
///
/// Unreachable without a pending request — the router's guard sends a direct
/// visit back to `/login`, because without a phone number there is nothing to
/// verify against.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();

  Timer? _countdownTimer;
  int _resendSeconds = 0;
  bool _isSubmitting = false;
  bool _isResending = false;
  Object? _error;

  /// True while the field is being emptied in response to a rejected code, so
  /// the controller listener does not treat it as the user editing.
  bool _isClearingAfterFailure = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCountdown());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController
      ..removeListener(_onCodeChanged)
      ..dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    // Guarded: clearing the field after a failed attempt fires this listener,
    // and without the guard it would wipe the "wrong code" message in the same
    // frame it was set — the user would see the field empty itself with no
    // explanation.
    if (_error != null && !_isClearingAfterFailure) {
      setState(() => _error = null);
    }

    // Submit as soon as the last digit lands. The code is fixed-length and
    // arrives by SMS, so making someone type six digits and then reach for a
    // button is a step with no decision in it.
    if (OtpPolicy.isWellFormedCode(_codeController.text) && !_isSubmitting) {
      unawaited(_submit());
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _tickCountdown();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
  }

  void _tickCountdown() {
    final receipt = ref.read(pendingOtpProvider);
    final remaining = receipt?.resendCountdownSeconds(DateTime.now()) ?? 0;
    if (remaining == _resendSeconds) {
      if (remaining == 0) _countdownTimer?.cancel();
      return;
    }
    if (!mounted) return;
    setState(() => _resendSeconds = remaining);
    if (remaining == 0) _countdownTimer?.cancel();
  }

  Future<void> _submit() async {
    final receipt = ref.read(pendingOtpProvider);
    if (receipt == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(verifyOtpProvider)(
        phone: receipt.phone,
        code: _codeController.text,
      );
      if (!mounted) return;
      // The session is now active; clearing the pending request re-locks this
      // route so a back-swipe cannot land on a dead verification screen.
      ref.read(pendingOtpProvider.notifier).clear();
      // Navigation itself is the router's job — the redirect rules send the
      // user to /consent or /home depending on what the server said about
      // their consent state, which this screen has no business deciding.
    } on Object catch (error) {
      if (!mounted) return;
      _isClearingAfterFailure = true;
      _codeController.clear();
      _isClearingAfterFailure = false;
      setState(() => _error = error);
      _codeFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resend() async {
    final receipt = ref.read(pendingOtpProvider);
    if (receipt == null || _isResending) return;

    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final resent = await ref.read(requestOtpProvider)(
        receipt.phone,
        previous: receipt,
      );
      if (!mounted) return;
      ref.read(pendingOtpProvider.notifier).begin(resent);
      _codeController.clear();
      _startCountdown();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _changeNumber() {
    ref.read(pendingOtpProvider.notifier).clear();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final receipt = ref.watch(pendingOtpProvider);

    // The guard normally prevents this, but a rebuild can race a clear.
    if (receipt == null) return const SizedBox.shrink();

    final canResend = _resendSeconds == 0 && !_isResending;

    return AuthScaffold.immersive(
      title: l10n.otpTitle,
      // Masked, never the full number — see MoroccanPhoneNumber.
      subtitle: l10n.otpSentTo(receipt.phone.masked),
      error: _error,
      onBack: _changeNumber,
      children: [
        OtpBoxes(
          controller: _codeController,
          focusNode: _codeFocus,
          enabled: !_isSubmitting,
        ),
        const SizedBox(height: RaeedSpacing.xl2),
        FilledButton(
          onPressed:
              _isSubmitting || !OtpPolicy.isWellFormedCode(_codeController.text)
              ? null
              : _submit,
          child: _isSubmitting
              ? const AuthButtonSpinner()
              : Text(l10n.otpVerify),
        ),
        const SizedBox(height: RaeedSpacing.lg),
        TextButton(
          onPressed: canResend ? _resend : null,
          child: Text(
            canResend ? l10n.otpResend : l10n.otpResendIn(_resendSeconds),
            style: context.type.button.copyWith(
              color: canResend ? palette.primary : palette.inkDim,
            ),
          ),
        ),
      ],
    );
  }
}
