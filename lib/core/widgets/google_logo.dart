import 'package:flutter/material.dart';

/// The official four-color Google "G" mark, painted with [CustomPainter] so it
/// ships no network/asset dependency and renders identically in tests.
///
/// Colors follow Google's brand palette (blue/green/yellow/red). The geometry
/// is a faithful, simplified reproduction of the "G" for use on the
/// branded sign-in button.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);
    final radius = s / 2;
    final strokeWidth = s * 0.26;
    final arcRadius = radius - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Four arcs forming the ring of the "G" (degrees → radians).
    void arc(double startDeg, double sweepDeg, Color color) {
      paint.color = color;
      canvas.drawArc(
        rect,
        startDeg * 0.0174532925,
        sweepDeg * 0.0174532925,
        false,
        paint,
      );
    }

    arc(-20, -140, _red); // top-left, red
    arc(-160, -110, _yellow); // bottom-left, yellow
    arc(90, 70, _green); // bottom-right, green
    arc(-20, -50, _blue); // right, blue

    // The horizontal bar of the "G".
    final barPaint = Paint()..color = _blue;
    final barRect = Rect.fromLTWH(
      center.dx,
      center.dy - strokeWidth / 2,
      arcRadius + strokeWidth / 2,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
