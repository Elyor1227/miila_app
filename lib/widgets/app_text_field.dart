import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Nom + input maydon birgalikda (Figma'dagi forma uslubi: label ustida, input ostida)
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// SMS tasdiqlash uchun 4 xonali kod kiritish maydonlari
class PinCodeBoxes extends StatelessWidget {
  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const PinCodeBoxes({
    super.key,
    this.length = 4,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 56,
            height: 64,
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: AppTextStyles.h2,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.pink, width: 1.6),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && i < length - 1) {
                  focusNodes[i + 1].requestFocus();
                } else if (value.isEmpty && i > 0) {
                  focusNodes[i - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}

/// Sonli stepper (masalan sikl uzunligi: - 28 +)
class StepperField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const StepperField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Row(
            children: [
              _roundBtn(Icons.remove, onDecrement),
              SizedBox(
                width: 72,
                child: Text(
                  valueLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h4,
                ),
              ),
              _roundBtn(Icons.add, onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.deep),
      ),
    );
  }
}
