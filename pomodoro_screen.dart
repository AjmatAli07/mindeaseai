import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int focusMinutes = 25;
  int focusSeconds = 0;
  int breakMinutes = 5;
  int breakSeconds = 0;

  late int remainingSeconds;
  bool isRunning = false;
  bool isFocusTime = true;

  Timer? _timer;

  final _focusMinCtrl = TextEditingController(text: "25");
  final _focusSecCtrl = TextEditingController(text: "0");
  final _breakMinCtrl = TextEditingController(text: "5");
  final _breakSecCtrl = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    remainingSeconds = _focusTotalSeconds();
  }

  int _focusTotalSeconds() => (focusMinutes * 60) + focusSeconds;
  int _breakTotalSeconds() => (breakMinutes * 60) + breakSeconds;

  void startTimer() {
    if (isRunning || _focusTotalSeconds() == 0) return;

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();

        setState(() {
          isRunning = false;
          isFocusTime = !isFocusTime;
          remainingSeconds =
              isFocusTime ? _focusTotalSeconds() : _breakTotalSeconds();
        });

        _showMoodDialog();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isFocusTime = true;
      remainingSeconds = _focusTotalSeconds();
    });
  }

  String formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void _updateTimes() {
    setState(() {
      focusMinutes = int.tryParse(_focusMinCtrl.text) ?? 0;
      focusSeconds = int.tryParse(_focusSecCtrl.text) ?? 0;
      breakMinutes = int.tryParse(_breakMinCtrl.text) ?? 0;
      breakSeconds = int.tryParse(_breakSecCtrl.text) ?? 0;

      if (isFocusTime) {
        remainingSeconds = _focusTotalSeconds();
      }
    });
  }

  void _showMoodDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("How do you feel now?"),
        content: const Text("Checking in helps you understand your stress level."),
        actions: const [
          Text("😌 Calm"),
          Text("🙂 Okay"),
          Text("😣 Stressed"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusMinCtrl.dispose();
    _focusSecCtrl.dispose();
    _breakMinCtrl.dispose();
    _breakSecCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds =
        isFocusTime ? _focusTotalSeconds() : _breakTotalSeconds();
    final progress =
        totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pomodoro Focus Timer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFocusTime ? "Focus Time" : "Break Time",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // ⏱ Custom Input
            _timeInputRow(
              title: "Focus",
              minCtrl: _focusMinCtrl,
              secCtrl: _focusSecCtrl,
              enabled: !isRunning,
            ),
            _timeInputRow(
              title: "Break",
              minCtrl: _breakMinCtrl,
              secCtrl: _breakSecCtrl,
              enabled: !isRunning,
            ),

            ElevatedButton(
              onPressed: isRunning ? null : _updateTimes,
              child: const Text("Apply Time"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress, strokeWidth: 10),
                  Text(
                    formatTime(remainingSeconds),
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: startTimer, child: const Text("Start")),
                ElevatedButton(onPressed: pauseTimer, child: const Text("Pause")),
                OutlinedButton(onPressed: resetTimer, child: const Text("Reset")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeInputRow({
    required String title,
    required TextEditingController minCtrl,
    required TextEditingController secCtrl,
    required bool enabled,
  }) {
    return Column(
      children: [
        Text("$title Time"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numberBox(minCtrl, "min", enabled),
            const SizedBox(width: 8),
            _numberBox(secCtrl, "sec", enabled),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _numberBox(
      TextEditingController controller, String label, bool enabled) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
