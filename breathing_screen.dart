import 'dart:async';
import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({Key? key}) : super(key: key);

  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String _phaseText = "Inhale";
  int _secondsLeft = 4;

  Timer? _timer;
  int _phaseIndex = 0;

  final List<String> _phases = ["Inhale", "Hold", "Exhale"];
  final List<double> _scales = [1.3, 1.3, 0.8];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation =
        Tween<double>(begin: 1.0, end: _scales[0]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startBreathing();
  }

  void _startBreathing() {
    _controller.forward();
    _secondsLeft = 4;
    _phaseText = _phases[_phaseIndex];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft == 0) {
        _phaseIndex = (_phaseIndex + 1) % _phases.length;

        _controller.reset();
        _controller.animateTo(
          _scales[_phaseIndex],
          duration: const Duration(seconds: 4),
          curve: Curves.easeInOut,
        );

        setState(() {
          _phaseText = _phases[_phaseIndex];
          _secondsLeft = 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Breathing Exercise"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _phaseText,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "$_secondsLeft",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Breathe slowly and focus on the movement",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
