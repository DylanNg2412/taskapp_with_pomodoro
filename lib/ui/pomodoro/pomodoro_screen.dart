import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/model/task_status.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key, this.task});
  final Task? task;

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
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task?.status == TaskStatus.completed;
  }

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

  void _completeTask() async {
    if (widget.task == null) return;

    try {
      final updatedTask = widget.task!.copy(status: TaskStatus.completed);
      final repo = TaskRepoSupabase();
      await repo.updateTask(updatedTask);

      if (!mounted) return;
      _showSnackbar('Task complete!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Failed to complete task: $e', isSuccess: false);
      debugPrint("Complete task error: $e");
    }
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
        return const Color.fromARGB(255, 167, 71, 71);
      case TimerMode.shortBreak:
        return Color.fromARGB(255, 15, 126, 65);
      case TimerMode.longBreak:
        return Color.fromARGB(255, 57, 113, 150);
    }
  }

  Color getTextColor() {
    switch (currentMode) {
      case TimerMode.pomodoro:
        return const Color.fromARGB(255, 167, 71, 71);
      case TimerMode.shortBreak:
        return Color.fromARGB(255, 15, 126, 65);
      case TimerMode.longBreak:
        return Color.fromARGB(255, 57, 113, 150);
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSnackbar(String msg, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
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
      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double buttonWidth =
                        (constraints.maxWidth - 16) / 3;
                    return ToggleButtons(
                      isSelected: [
                        currentMode == TimerMode.pomodoro,
                        currentMode == TimerMode.shortBreak,
                        currentMode == TimerMode.longBreak,
                      ],
                      onPressed: (index) {
                        switchMode(TimerMode.values[index]);
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedBorderColor: Colors.transparent,
                      borderColor: Colors.transparent,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      selectedColor: Colors.white,
                      color: Colors.white.withValues(alpha: 0.7),
                      constraints: BoxConstraints(
                        minHeight: 45,
                        maxWidth: buttonWidth,
                        minWidth: buttonWidth,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Pomodoro'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Short Break'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Long Break'),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(flex: 2),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value:
                          _getProgress(),
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        formatTime(timeRemaining),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getModeLabel(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    label: isRunning ? 'Pause' : 'Start',
                    onPressed: isRunning ? _pauseTimer : _startTimer,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 24),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Reset',
                    onPressed: _resetTimer,
                    isPrimary: false,
                  ),
                ],
              ),

              const Spacer(flex: 1),

              if (widget.task != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.task_alt, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Current Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() => isChecked = value!);
                              },
                              activeColor: getBackgroundColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.task!.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                  decoration:
                                      isChecked
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _completeTask,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Complete Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: getBackgroundColor(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for control buttons
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? getBackgroundColor() : Colors.white,
        side:
            isPrimary ? null : const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isPrimary ? 4 : 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  double _getProgress() {
    int totalDuration;
    switch (currentMode) {
      case TimerMode.pomodoro:
        totalDuration = 25 * 60;
        break;
      case TimerMode.shortBreak:
        totalDuration = 5 * 60;
        break;
      case TimerMode.longBreak:
        totalDuration = 15 * 60;
        break;
    }
    return (totalDuration - timeRemaining) / totalDuration;
  }

  String _getModeLabel() {
    switch (currentMode) {
      case TimerMode.pomodoro:
        return 'Focus Time';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }
}
