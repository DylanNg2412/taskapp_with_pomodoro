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
      if (id != null) 'id': id,
      "task_id": taskId,
      "duration": duration,
      "completed_at": completedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return "PomodoroSessions(id: $id, taskId: $taskId, duration: $duration, completedAt: $completedAt)";
  }

  static PomodoroSessions fromMap(Map<String, dynamic> map) {
    return PomodoroSessions(
      id: map["id"],
      taskId: map["task_id"],
      duration: map["duration"],
      completedAt: DateTime.parse(map["completed_at"]),
    );
  }
}
