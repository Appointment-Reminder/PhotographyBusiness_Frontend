// lib/core/presentation/widgets/unconfigured_cell_icon.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';

class UnconfiguredCellIcon extends StatelessWidget {
  final bool isHovered;
  const UnconfiguredCellIcon({super.key, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: isHovered
              ? AppColors.primaryText.withOpacity(0.4)
              : AppColors.border,
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 12,
            color: isHovered ? AppColors.primaryText : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 1;
    const dashCount = 10;
    const dashAngle = math.pi * 2 / dashCount;
    const gapRatio = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}