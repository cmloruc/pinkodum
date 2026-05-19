import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PinCodeDisplay extends StatelessWidget {
  final List<int> pinCode;
  final bool large;

  const PinCodeDisplay({
    super.key,
    required this.pinCode,
    this.large = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: large ? 4 : 2,
      runSpacing: large ? 8 : 4,
      children: List.generate(pinCode.length, (i) {
        return _DigitBubble(
          digit: pinCode[i],
          color: AppColors.pinDigitColors[i % AppColors.pinDigitColors.length],
          large: large,
        );
      }),
    );
  }
}

class _DigitBubble extends StatelessWidget {
  final int digit;
  final Color color;
  final bool large;

  const _DigitBubble({
    required this.digit,
    required this.color,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 48.0 : 34.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$digit',
        style: large
            ? AppTextStyles.pinDigit.copyWith(color: color)
            : AppTextStyles.pinDigitSmall.copyWith(color: color, fontSize: 14),
      ),
    );
  }
}
