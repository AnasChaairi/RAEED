import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/otp_policy.dart';

/// The design's six-cell code entry.
///
/// One real `TextField` behind six drawn boxes, rather than six fields wired
/// together. Six fields means six focus nodes, six listeners, and hand-rolled
/// backspace and paste behaviour that never quite matches the platform — and
/// autofill, which is what actually gets the code in from the SMS, only ever
/// targets one field. The boxes are presentation; the input is ordinary.
///
/// Cells fill left-to-right regardless of locale: a numeric code is read in
/// that order in Arabic too, and mirroring it would put the first digit typed
/// under the last box.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    this.onCompleted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  /// Called once the final digit lands.
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // The real field, invisible but fully functional: it holds focus, takes
      // the keyboard, and receives the one-time-code autofill.
      SizedBox(
        height: _cellHeight,
        child: Opacity(
          opacity: 0,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            enabled: enabled,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(OtpPolicy.codeLength),
            ],
            onChanged: (value) {
              if (value.length == OtpPolicy.codeLength) onCompleted?.call();
            },
            decoration: const InputDecoration(counterText: ''),
          ),
        ),
      ),
      // Tapping anywhere on the boxes focuses the field behind them.
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? focusNode.requestFocus : null,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => _Cells(
              code: value.text,
              hasFocus: focusNode.hasFocus,
              enabled: enabled,
            ),
          ),
        ),
      ),
    ],
  );

  static const double _cellHeight = 52;
}

class _Cells extends StatelessWidget {
  const _Cells({
    required this.code,
    required this.hasFocus,
    required this.enabled,
  });

  final String code;
  final bool hasFocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      label: '${code.length}/${OtpPolicy.codeLength}',
      textField: true,
      child: Directionality(
        // Digits read left-to-right in every locale RAEED ships.
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < OtpPolicy.codeLength; index++) ...[
              if (index > 0) const SizedBox(width: RaeedSpacing.sm),
              Flexible(
                child: _Cell(
                  digit: index < code.length ? code[index] : null,
                  isNext: enabled && hasFocus && index == code.length,
                  palette: palette,
                  context: context,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.isNext,
    required this.palette,
    required this.context,
  });

  final String? digit;
  final bool isNext;
  final RaeedPalette palette;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final isFilled = digit != null;

    return Container(
      constraints: const BoxConstraints(minWidth: 40, maxWidth: 52),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Filled cells take the primary fill; the next cell is outlined in the
        // bright end of the gradient; the rest stay quiet.
        color: isFilled
            ? palette.primary
            : isNext
            ? palette.primarySoft
            : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        border: isNext ? Border.all(color: palette.info, width: 2) : null,
      ),
      child: isFilled
          ? Text(
              digit!,
              style: context.type
                  .tabular(context.type.h3)
                  .copyWith(color: palette.primaryOn),
            )
          : isNext
          // The caret, drawn rather than animated: a blinking bar in six
          // boxes is noise, and the outline already says where you are.
          ? Container(width: 2, height: 22, color: palette.info)
          : null,
    );
  }
}
