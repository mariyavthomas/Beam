// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ButtonScreen extends StatefulWidget {
  const ButtonScreen({super.key});

  @override
  _ButtonScreenState createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 6), // Faster animation for seamless effect
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BeamBorderPainter(_controller.value),
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  'Border',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BeamBorderPainter extends CustomPainter {
  final double progress;

  BeamBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Static Border Paint with Solid Color
    final Paint borderPaint = Paint()
      ..color = const Color.fromARGB(255, 106, 106, 106) // Same border color
      ..strokeWidth = 1 // Thin border
      ..style = PaintingStyle.stroke;

    // Moving Beam Paint with Gradient
    final Paint beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueAccent, Colors.pinkAccent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1 // Beam thickness
      ..style = PaintingStyle.stroke;

    final Path borderPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(15)));

    // Draw the static border
    canvas.drawPath(borderPath, borderPaint);

    // Continuous beam position calculation
    final PathMetric pathMetric = borderPath.computeMetrics().first;
    final double pathLength = pathMetric.length;
    final double beamLength = 150; // Beam length
    final double beamStart = pathLength * progress; // Continuous movement
    final double beamEnd = beamStart + beamLength;

    // Create the beam path with wrapping
    final Path beamPath = Path();
    if (beamEnd <= pathLength) {
      // Beam is within the path
      beamPath.addPath(pathMetric.extractPath(beamStart, beamEnd), Offset.zero);
    } else {
      // Beam exceeds the path length, wrap it around
      beamPath.addPath(
          pathMetric.extractPath(beamStart, pathLength), Offset.zero);
      beamPath.addPath(
          pathMetric.extractPath(0, beamEnd - pathLength), Offset.zero);
    }

    // Draw the moving beam
    canvas.drawPath(beamPath, beamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
