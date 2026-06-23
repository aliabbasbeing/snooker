import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
