import 'package:flutter/material.dart';

class CenteredTabIndicator extends Decoration {
  final Color color;
  final double indicatorHeight;
  final double indicatorWidth;
  final bool isGradient;
  final double radius;

  const CenteredTabIndicator({
    required this.color,
    this.indicatorHeight = 3.0,
    this.indicatorWidth = 120,
    this.isGradient = true,
    this.radius = 2.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CenteredTabIndicatorPainter(
      color: color,
      indicatorHeight: indicatorHeight,
      indicatorWidth: indicatorWidth,
      isGradient: isGradient,
      radius: radius,
    );
  }
}

class _CenteredTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double indicatorHeight;
  final double indicatorWidth;
  final bool isGradient;
  final double radius;

  _CenteredTabIndicatorPainter({
    required this.color,
    required this.indicatorHeight,
    required this.indicatorWidth,
    required this.isGradient,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final tabWidth = configuration.size!.width;
    final leftOffset = (tabWidth - indicatorWidth) / 2;

    final rect = Rect.fromLTWH(
      offset.dx + leftOffset,
      offset.dy + configuration.size!.height - indicatorHeight,
      indicatorWidth,
      indicatorHeight,
    );

    if (isGradient) {
      final gradient = LinearGradient(
        colors: [
          color.withOpacity(0.8),
          color,
          color.withOpacity(0.8),
        ],
        stops: [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
    } else {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
    }
  }
}