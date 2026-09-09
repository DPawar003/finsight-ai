import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FinancialPulse extends StatefulWidget {
  final double size;
  const FinancialPulse({super.key, this.size = 160});

  @override
  State<FinancialPulse> createState() => _FinancialPulseState();
}

class _FinancialPulseState extends State<FinancialPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _PulsePainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  _PulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow ring, pulsing
    final glowPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.primary.withOpacity(0.0),
          AppColors.primary.withOpacity(0.5),
          AppColors.aiCyanDark.withOpacity(0.5),
          AppColors.primary.withOpacity(0.0),
        ],
        startAngle: 0,
        endAngle: 2 * pi,
        transform: GradientRotation(progress * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 6, glowPaint);

    // Inner soft fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.15),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7));
    canvas.drawCircle(center, radius * 0.7, fillPaint);

    // Center icon-like mark (upward growth line)
    final linePaint = Paint()
      ..color = AppColors.aiCyanDark
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = radius * 0.6;
    final h = radius * 0.5;
    path.moveTo(center.dx - w / 2, center.dy + h / 3);
    path.lineTo(center.dx - w / 6, center.dy - h / 6);
    path.lineTo(center.dx + w / 6, center.dy + h / 8);
    path.lineTo(center.dx + w / 2, center.dy - h / 2);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => true;
}