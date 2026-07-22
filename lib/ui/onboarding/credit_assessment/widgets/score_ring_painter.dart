
// Extracted unchanged from the original screen.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScoreRingPainter extends CustomPainter {
  const ScoreRingPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 16) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}