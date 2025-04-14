import 'package:flutter/material.dart';

class PhoenixLogo extends StatelessWidget {
  final double size;

  const PhoenixLogo({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PhoenixPainter(),
      ),
    );
  }
}

class PhoenixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Drawing the phoenix shape
    path.moveTo(size.width * 0.5, size.height * 0.1); // Head
    path.lineTo(size.width * 0.3, size.height * 0.4); // Left wing
    path.lineTo(size.width * 0.5, size.height * 0.6); // Body
    path.lineTo(size.width * 0.7, size.height * 0.4); // Right wing
    path.close();

    // Drawing the wings
    final leftWing = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.15, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..close();

    final rightWing = Path()
      ..moveTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 