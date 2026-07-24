import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single big-number KPI tile (e.g. "Total billed - ₹53,10,00.00").
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? caption;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12, letterSpacing: 0.3),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ],
    );
  }
}
