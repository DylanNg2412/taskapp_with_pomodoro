import 'package:taskapp_with_pomodoro/data/model/task_prio.dart';
import 'package:taskapp_with_pomodoro/data/model/task_status.dart';

class Task {
  int? id;
  final String title;
  final String? body;
  final TaskStatus status;
  final TaskPriority priority;
  final String img;
  final String? userId;
  final DateTime? completedAt;

  static const name = "tasks";

  Task({
    this.id,
    required this.title,
    this.body,
    this.status = TaskStatus.planned,
    this.priority = TaskPriority.medium, // medium serves as a middle ground
    this.img = "",
    required this.userId,
    this.completedAt,
  });

  Task copy({
    int? id,
    String? title,
    String? body,
    TaskStatus? status,
    TaskPriority? priority,
    String? img,
    String? userId,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      img: img ?? this.img,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
      "status": status.name,
      "priority": priority.name,
      "img": img,
      "user_id": userId,
      "completed_at": completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return "Task(id: $id, title: $title, body: $body, status: ${status.name}, priority: ${priority.name}, img: $img, userId: $userId, completedAt: $completedAt)";
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map["id"],
      title: map["title"],
      body: map["body"],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map["status"],
        orElse: () => TaskStatus.planned,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map["priority"],
        orElse: () => TaskPriority.medium,
      ),
      img: map["img"],
      userId: map["user_id"],
      completedAt:
          map['completed_at'] != null
              ? DateTime.tryParse(map['completed_at'].toString())
              : null,
    );
  }
}



