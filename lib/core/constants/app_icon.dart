import 'package:flutter/material.dart';

/// Sage leaf icon widget for use in the app
class SageLeafIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SageLeafIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SageLeafPainter(color: color ?? const Color(0xFF4CAF50)),
    );
  }
}

class SageLeafPainter extends CustomPainter {
  final Color color;

  SageLeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a simple sage leaf shape
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Leaf outline
    path.moveTo(centerX, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.85, centerY,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.7,
      centerX, size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.7,
      size.width * 0.15, centerY,
    );
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.3,
      centerX, size.height * 0.1,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Draw leaf vein
    final veinPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;

    final veinPath = Path();
    veinPath.moveTo(centerX, size.height * 0.1);
    veinPath.lineTo(centerX, size.height * 0.9);

    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
