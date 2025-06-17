import 'dart:ui';

import 'package:flutter/material.dart';

class GradientHalfScreenTabIndicator extends Decoration {
  final Color color;
  final TabController tabController;

  GradientHalfScreenTabIndicator({
    required this.color,
    required this.tabController,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientHalfTabIndicatorPainter(
      color: color,
      tabController: tabController,
    );
  }
}

class _GradientHalfTabIndicatorPainter extends BoxPainter {
  final Color color;
  final TabController tabController;

  _GradientHalfTabIndicatorPainter({
    required this.color,
    required this.tabController,
  });
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final double screenWidth = configuration.size!.width*2; // Total 2 tabs
    final bool isLeft = tabController.index == 0;

    final double indicatorWidth = screenWidth;
    final double indicatorHeight = 3;

    final double dx = isLeft ? 0 : indicatorWidth;

    final Rect rect = Rect.fromLTWH(
      dx,
      offset.dy + configuration.size!.height - indicatorHeight,
      indicatorWidth,
      indicatorHeight,
    );

    final gradient = LinearGradient(
      begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        color,
        color.withOpacity(0.0),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

}
