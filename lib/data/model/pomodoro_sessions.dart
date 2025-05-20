class PomodoroSessions {
  int? id;
  final int taskId;
  final int duration;
  final DateTime completedAt;

  static const name = "pomodoro_sessions";

  PomodoroSessions({
    this.id,
    required this.taskId,
    required this.duration,
    required this.completedAt,
  });

  PomodoroSessions copy({
    int? id,
    int? taskId,
    int? duration,
    DateTime? completedAt,
  }) {
    return PomodoroSessions(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      duration: duration ?? this.duration,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "taskId": taskId,
      "duration": duration,
      "completedAt": completedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return "PomodoroSessions(id: $id, taskId: $taskId, duration: $duration, completedAt: $completedAt)";
  }

  static PomodoroSessions fromMap(Map<String, dynamic> map) {
    return PomodoroSessions(
      id: map["id"],
      taskId: map["taskId"],
      duration: map["duration"],
      completedAt: DateTime.parse(map["completedAt"]),
    );
  }
}
