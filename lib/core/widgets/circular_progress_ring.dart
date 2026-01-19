import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anello circolare di progresso stile Apple Fitness.
/// Usare per tracking obiettivi giornalieri (calorie, acqua, attività).
class CircularProgressRing extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;
  final String? centerValue;
  final String? centerLabel;
  final IconData? centerIcon;
  final Widget? child;
  final bool animate;
  final bool showGlow;
  final Duration animationDuration;

  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    required this.color,
    this.backgroundColor,
    this.strokeWidth = 12,
    this.centerValue,
    this.centerLabel,
    this.centerIcon,
    this.child,
    this.animate = true,
    this.showGlow = true,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
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
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: widget.animate ? _animation.value : widget.progress,
              color: widget.color,
              backgroundColor:
                  widget.backgroundColor ?? widget.color.withValues(alpha: 0.15),
              strokeWidth: widget.strokeWidth,
              showGlow: widget.showGlow,
            ),
            child: Center(
              child: widget.child ?? _buildCenterContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.centerIcon != null)
          Icon(
            widget.centerIcon,
            color: widget.color,
            size: widget.size * 0.2,
          ),
        if (widget.centerValue != null) ...[
          if (widget.centerIcon != null) const SizedBox(height: 4),
          Text(
            widget.centerValue!,
            style: TextStyle(
              fontSize: widget.size * 0.18,
              fontWeight: FontWeight.w700,
              color: widget.color,
            ),
          ),
        ],
        if (widget.centerLabel != null)
          Text(
            widget.centerLabel!,
            style: TextStyle(
              fontSize: widget.size * 0.1,
              fontWeight: FontWeight.w500,
              color: widget.color.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final bool showGlow;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    this.showGlow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          color,
          color.withValues(alpha: 0.8),
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect at the end
    if (showGlow && progress > 0.05) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final endAngle = -math.pi / 2 + sweepAngle;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      canvas.drawCircle(endPoint, strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Multi-ring progress (stile Apple Fitness con 3 anelli concentrici)
class MultiRingProgress extends StatelessWidget {
  final List<RingData> rings;
  final double size;
  final double ringSpacing;

  const MultiRingProgress({
    super.key,
    required this.rings,
    this.size = 200,
    this.ringSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(rings.length, (index) {
          final ringSize = size - (index * ringSpacing * 2);
          final ring = rings[index];
          return CircularProgressRing(
            progress: ring.progress,
            size: ringSize,
            color: ring.color,
            strokeWidth: 10,
          );
        }),
      ),
    );
  }
}

/// Data per un singolo anello
class RingData {
  final double progress;
  final Color color;
  final String label;

  const RingData({
    required this.progress,
    required this.color,
    required this.label,
  });
}
