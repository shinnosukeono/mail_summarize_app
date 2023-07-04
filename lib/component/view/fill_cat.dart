import 'package:flutter/material.dart';

class CatFacePainter extends CustomPainter {
  final double fillHeight;

  CatFacePainter({required this.fillHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw the face
    path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2));

    // Draw the ears
    path.moveTo(
        size.width / 2 - size.width / 3, size.height / 2 - size.height / 3);
    path.lineTo(size.width / 2, 0);
    path.lineTo(
        size.width / 2 + size.width / 3, size.height / 2 - size.height / 3);
    path.close();

    canvas.drawPath(path, paint);

    // Draw the fill color
    final fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final fillPath = Path();

    fillPath.moveTo(0, size.height * (1 - fillHeight));
    fillPath.lineTo(size.width, size.height * (1 - fillHeight));
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class FillCatFace extends StatefulWidget {
  const FillCatFace({Key? key}) : super(key: key);
  @override
  State<FillCatFace> createState() => _FillCatFaceState();
}

class _FillCatFaceState extends State<FillCatFace>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: CatFacePainter(fillHeight: _animationController.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class FillCircle extends StatefulWidget {
  const FillCircle({Key? key}) : super(key: key);
  @override
  State<FillCircle> createState() => _FillCircleState();
}

class _FillCircleState extends State<FillCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            size: const Size(200, 200),
            painter: CirclePainter(fillHeight: _controller.value),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final double fillHeight;

  CirclePainter({required this.fillHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * (1 - fillHeight))
      ..arcToPoint(
        Offset(0, size.height * (1 - fillHeight)),
        radius: Radius.circular(size.width / 2),
        largeArc: false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.fillHeight != fillHeight;
}
