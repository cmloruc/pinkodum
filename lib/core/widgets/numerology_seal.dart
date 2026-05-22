import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class NumerologySeal extends StatelessWidget {
  final double size;
  final bool showNumbers;
  final String center;

  const NumerologySeal({
    super.key,
    this.size = 210,
    this.showNumbers = true,
    this.center = 'P',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.purple.withValues(alpha: 0.2),
              AppColors.purple.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _SealPainter(showNumbers: showNumbers),
          child: Center(
            child: Text(
              center,
              style: GoogleFonts.playfairDisplay(
                color: AppColors.goldLight,
                fontSize: size * 0.31,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  final bool showNumbers;

  const _SealPainter({required this.showNumbers});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.36;
    final line = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final innerLine = Paint()
      ..color = AppColors.purpleLight.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final spark = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.76)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, line);
    canvas.drawCircle(center, radius * 0.77, innerLine);
    canvas.drawCircle(center, radius * 0.48, innerLine);

    for (var ring = 0; ring < 4; ring++) {
      final rect = Rect.fromCircle(center: center, radius: radius * 0.73);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ring * math.pi / 8);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(
          rect.inflate(ring.isEven ? 0 : -radius * 0.13), innerLine);
      canvas.restore();
    }

    final points = List.generate(8, (index) {
      final angle = -math.pi / 2 + (math.pi * 2 * index / 8);
      return Offset(
        center.dx + math.cos(angle) * radius * 0.77,
        center.dy + math.sin(angle) * radius * 0.77,
      );
    });
    for (var index = 0; index < points.length; index++) {
      canvas.drawLine(
          points[index], points[(index + 3) % points.length], innerLine);
    }

    for (var index = 0; index < 10; index++) {
      final angle = index * math.pi / 5;
      final distance = radius * (1.05 + (index % 3) * 0.16);
      final point = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      canvas.drawLine(point.translate(-2.4, 0), point.translate(2.4, 0), spark);
      canvas.drawLine(point.translate(0, -2.4), point.translate(0, 2.4), spark);
    }

    if (!showNumbers) return;
    final digits = ['7', '3', '2', '6', '8', '9'];
    for (var index = 0; index < digits.length; index++) {
      final angle = -math.pi / 2 + (math.pi * 2 * index / digits.length);
      final painter = TextPainter(
        text: TextSpan(
          text: digits[index],
          style: GoogleFonts.playfairDisplay(
            color: index.isEven ? AppColors.goldLight : AppColors.purpleLight,
            fontSize: size.shortestSide * 0.13,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          center.dx + math.cos(angle) * radius * 1.05 - painter.width / 2,
          center.dy + math.sin(angle) * radius * 1.05 - painter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => true;
}
