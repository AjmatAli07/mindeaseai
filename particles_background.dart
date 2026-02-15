import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesBackground extends StatefulWidget {
  const ParticlesBackground({super.key});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  final List<_Particle> particles = [];

  @override
  void initState() {
    super.initState();

    final random = Random();

    for (int i = 0; i < 25; i++) {
      particles.add(
        _Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 10 + 5, // BIGGER
          speed: random.nextDouble() * 0.003 + 0.001,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        for (var p in particles) {
          p.y -= p.speed;
          if (p.y < 0) {
            p.y = 1;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _ParticlePainter(particles),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white; // FULL WHITE

    for (var p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
