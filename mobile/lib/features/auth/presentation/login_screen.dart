import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../domain/moroccan_phone_number.dart';
import '../domain/password_policy.dart';
import 'auth_providers.dart';
import 'auth_scaffold.dart';

/// Phone number and password — the entire sign-in form (`RAEED-2`).
///
/// There is no "create account" link and no "forgot password" link, and both
/// absences are deliberate. Registration is Executive/Admin only (`ACC-02`),
/// and a password is handed over by the association in person — so a family
/// who cannot sign in needs the association, not a form, and the screen says
/// so plainly instead of leaving them hunting for a button that does not
/// exist.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  /// Set once the user has tried to submit, so the fields do not turn red
  /// while they are still typing the first three digits.
  bool _showValidation = false;
  bool _isSubmitting = false;
  bool _revealPassword = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onEdited);
    _passwordController.addListener(_onEdited);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onEdited)
      ..dispose();
    _passwordController
      ..removeListener(_onEdited)
      ..dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEdited() {
    // Clearing the error as soon as they edit keeps a stale "not correct"
    // from sitting under a value they have since corrected.
    if (_error != null || _showValidation) {
      setState(() {
        _error = null;
        _showValidation = false;
      });
    }
  }

  String? get _phoneValidationError {
    if (!_showValidation) return null;
    return MoroccanPhoneNumber.isValid(_phoneController.text)
        ? null
        : AppL10n.of(context).loginPhoneInvalid;
  }

  String? get _passwordValidationError {
    if (!_showValidation) return null;
    return PasswordPolicy.isWellFormed(_passwordController.text)
        ? null
        : AppL10n.of(context).loginPasswordInvalid;
  }

  Future<void> _submit() async {
    final phone = MoroccanPhoneNumber.tryParse(_phoneController.text);
    final password = _passwordController.text;
    if (phone == null || !PasswordPolicy.isWellFormed(password)) {
      setState(() => _showValidation = true);
      (phone == null ? _phoneFocus : _passwordFocus).requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(signInProvider)(phone: phone, password: password);
      // The router moves on by itself once the session controller announces
      // the signed-in user; nothing to navigate to here.
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
      error: _error,
      children: [
        // A phone number is left-to-right even inside an Arabic layout: the
        // country code sits at the left, the digits follow it and the cursor
        // moves right — so the whole field, not just its text, is LTR.
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            key: const Key('login-phone'),
            controller: _phoneController,
            focusNode: _phoneFocus,
            autofocus: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
            enabled: !_isSubmitting,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              LengthLimitingTextInputFormatter(_maxPhoneInputLength),
            ],
            style: context.type.body.copyWith(color: palette.ink),
            decoration: InputDecoration(
              labelText: l10n.loginPhoneLabel,
              hintText: l10n.loginPhoneHint,
              errorText: _phoneValidationError,
              prefixIcon: const _CountryCodePrefix(),
              prefixIconConstraints: const BoxConstraints(),
            ),
          ),
        ),
        const SizedBox(height: RaeedSpacing.lg),
        TextField(
          key: const Key('login-password'),
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: !_revealPassword,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isSubmitting ? null : _submit(),
          enabled: !_isSubmitting,
          // Six letters or digits read left-to-right like the number does.
          textDirection: TextDirection.ltr,
          textAlign: context.isRtl ? TextAlign.end : TextAlign.start,
          autofillHints: const [AutofillHints.password],
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(PasswordPolicy.length),
          ],
          style: context.type.body.copyWith(color: palette.ink),
          decoration: InputDecoration(
            labelText: l10n.loginPasswordLabel,
            helperText: l10n.loginPasswordRule,
            errorText: _passwordValidationError,
            suffixIcon: IconButton(
              tooltip: _revealPassword
                  ? l10n.loginPasswordHide
                  : l10n.loginPasswordShow,
              onPressed: () =>
                  setState(() => _revealPassword = !_revealPassword),
              icon: Icon(
                _revealPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: palette.inkDim,
              ),
            ),
          ),
        ),
        const SizedBox(height: RaeedSpacing.xl2),
        FilledButton(
          key: const Key('login-submit'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const _ButtonSpinner()
              : Text(l10n.loginSubmit),
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

/// Exposed for the change-password screen, which shares the same in-button
/// spinner.
class AuthButtonSpinner extends StatelessWidget {
  const AuthButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) => const _ButtonSpinner();
}
