import 'package:flutter/material.dart';

class Task {
  int? id;
  final String title;
  final String body;
  final TaskStatus status;
  final String img;
  final String? userId;
  final DateTime? completedAt;

  static const name = "tasks";

  Task({
    this.id,
    required this.title,
    required this.body,
    this.status = TaskStatus.planned,
    this.img = "",
    required this.userId,
    this.completedAt,
  });

  Task copy({
    int? id,
    String? title,
    String? body,
    TaskStatus? status,
    String? img,
    String? userId,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
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
      "img": img,
      "user_id": userId,
      "completed_at": completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return "Task(id: $id, title: $title, body: $body, status: ${status.name}, img: $img, userId: $userId, completedAt: $completedAt)";
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
      img: map["img"],
      userId: map["user_id"],
      completedAt:
          map['completed_at'] != null
              ? DateTime.tryParse(map['completed_at'].toString())
              : null,
    );
  }
}

enum TaskStatus { planned, inProgress, completed }

extension TaskStatusToString on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.planned:
        return "Planned";
      case TaskStatus.inProgress:
        return "In Progress";
      case TaskStatus.completed:
        return "Completed";
    }
  }

  IconData get taskIcon {
    switch (this) {
      case TaskStatus.planned:
        return Icons.event_note;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty;
      case TaskStatus.completed:
        return Icons.check_box_rounded;
    }
  }

  Color get taskBgColor {
    switch (this) {
      case TaskStatus.planned:
        return Color.fromARGB(255, 186, 72, 72);
      case TaskStatus.inProgress:
        return Color.fromARGB(255, 33, 150, 243);
      case TaskStatus.completed:
        return Color.fromARGB(255, 5, 184, 95);
    }
  }
}
