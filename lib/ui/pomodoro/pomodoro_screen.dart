import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

enum TimerMode { pomodoro, shortBreak, longBreak }

class _PomodoroScreenState extends State<PomodoroScreen> {
  
  final Map<TimerMode, int> durations = {
    TimerMode.pomodoro: 25 * 60,
    TimerMode.shortBreak: 5 * 60,
    TimerMode.longBreak: 15 * 60,
  };

  TimerMode currentMode = TimerMode.pomodoro;
  int timeRemaining = 25 * 60;
  Timer? timer;
  bool isRunning = false;

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeRemaining > 0) {
        setState(() => timeRemaining--);
      } else {
        timer!.cancel();
        setState(() => isRunning = false);
      }
    });
    setState(() => isRunning = true);
  }

  void _pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    timer?.cancel();
    setState(() {
      timeRemaining = durations[currentMode]!;
      isRunning = false;
    });
  }

  void switchMode(TimerMode mode) {
    timer?.cancel();
    setState(() {
      currentMode = mode;
      timeRemaining = durations[mode]!;
      isRunning = false;
    });
  }

  Color getBackgroundColor() {
    switch (currentMode) {
      case TimerMode.pomodoro:
        return const Color.fromARGB(255, 186, 72, 72);
      case TimerMode.shortBreak:
        return Color.fromARGB(255, 57, 132, 138);
      case TimerMode.longBreak:
        return Color.fromARGB(255, 57, 113, 150);
    }
  }

  Color getTextColor() {
    switch (currentMode) {
      case TimerMode.pomodoro:
        return const Color.fromARGB(255, 186, 72, 72);
      case TimerMode.shortBreak:
        return Color.fromARGB(255, 57, 132, 138);
      case TimerMode.longBreak:
        return Color.fromARGB(255, 57, 113, 150);
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [
                currentMode == TimerMode.pomodoro,
                currentMode == TimerMode.shortBreak,
                currentMode == TimerMode.longBreak,
              ],
              onPressed: (index) {
                switchMode(TimerMode.values[index]);
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Pomodoro',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Short Break',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Long Break',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              formatTime(timeRemaining),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: getTextColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: getTextColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
