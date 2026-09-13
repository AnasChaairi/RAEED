import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../domain/moroccan_phone_number.dart';
import 'auth_providers.dart';
import 'auth_scaffold.dart';

/// Phone entry — the entire sign-in form (`RAEED-2`).
///
/// There is no password field and no "create account" link, and both absences
/// are deliberate. RAEED has no passwords at all
/// (`specs/10-security-and-privacy.md`), and registration is Executive/Admin
/// only (`ACC-02`) — there is no public sign-up endpoint to link to. A family
/// who cannot sign in needs the association, not a form, so the screen says so
/// plainly instead of leaving them hunting for a button that does not exist.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  /// Set once the user has tried to submit, so the field does not turn red
  /// while they are still typing the first three digits.
  bool _showValidation = false;
  bool _isSubmitting = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    // Clearing the error as soon as they edit keeps a stale "invalid number"
    // from sitting under a number they have since corrected.
    if (_error != null || _showValidation) {
      setState(() {
        _error = null;
        _showValidation = false;
      });
    }
  }

  String? get _validationError {
    if (!_showValidation) return null;
    return MoroccanPhoneNumber.isValid(_phoneController.text)
        ? null
        : AppL10n.of(context).loginPhoneInvalid;
  }

  Future<void> _submit() async {
    final phone = MoroccanPhoneNumber.tryParse(_phoneController.text);
    if (phone == null) {
      setState(() => _showValidation = true);
      _phoneFocus.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final receipt = await ref.read(requestOtpProvider)(phone);
      if (!mounted) return;
      ref.read(pendingOtpProvider.notifier).begin(receipt);
      context.go(AppRoutes.otp);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return AuthScaffold.immersive(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      tagline: l10n.brandTagline,
      error: _error,
      children: [
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          autofocus: true,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isSubmitting ? null : _submit(),
          enabled: !_isSubmitting,
          // A phone number reads left-to-right even inside an Arabic layout:
          // the country code belongs at the start of the number, not at the
          // visual end of an RTL line.
          textDirection: TextDirection.ltr,
          textAlign: context.isRtl ? TextAlign.end : TextAlign.start,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            LengthLimitingTextInputFormatter(_maxPhoneInputLength),
          ],
          style: context.type.body.copyWith(color: palette.ink),
          decoration: InputDecoration(
            labelText: l10n.loginPhoneLabel,
            hintText: l10n.loginPhoneHint,
            hintTextDirection: TextDirection.ltr,
            errorText: _validationError,
            prefixIcon: const _CountryCodePrefix(),
            prefixIconConstraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: RaeedSpacing.xl2),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const _ButtonSpinner()
              : Text(l10n.loginRequestCode),
        ),
        const SizedBox(height: RaeedSpacing.xl2),
        _AccountNotice(message: l10n.loginNoAccountNotice),
      ],
    );
  }

  /// Room for `00212` plus nine digits plus the separators people type, and no
  /// more — a longer string is never a Moroccan mobile number.
  static const int _maxPhoneInputLength =
      MoroccanPhoneNumber.nationalDigitCount + 12;
}

/// The country code, fixed inside the field as the design draws it.
///
/// Fixed rather than editable: RAEED is one association in one country, and a
/// country picker would be a control that is always set to the same value.
class _CountryCodePrefix extends StatelessWidget {
  const _CountryCodePrefix();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: RaeedSpacing.lg,
        end: RaeedSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${MoroccanPhoneNumber.countryCode}',
            textDirection: TextDirection.ltr,
            style: context.type.body.copyWith(color: palette.inkDim),
          ),
          const SizedBox(width: RaeedSpacing.md),
          Container(width: 1, height: 18, color: palette.border),
        ],
      ),
    );
  }
}

/// The "accounts are created by the association" note.
class _AccountNotice extends StatelessWidget {
  const _AccountNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: palette.inkDim),
          const SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Text(
              message,
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
            ),
          ),
        ],
      ),
    );
  }
}

/// A spinner sized to sit inside a button without changing its height.
class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 18,
    width: 18,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: context.palette.primaryOn,
    ),
  );
}

/// Exposed for the OTP screen, which shares the same in-button spinner.
class AuthButtonSpinner extends StatelessWidget {
  const AuthButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) => const _ButtonSpinner();
}
