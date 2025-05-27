import 'package:flutter/material.dart';

class Task {
  int? id;
  final String title;
  final String body;
  final TaskStatus status; // by default it should be "Planned"
  final String img;
  final String? userId;

  static const name = "tasks";

  Task({
    this.id,
    required this.title,
    required this.body,
    this.status = TaskStatus.planned,
    this.img = "",
    required this.userId,
  });

  Task copy({
    int? id,
    String? title,
    String? body,
    TaskStatus? status,
    String? img,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      img: img ?? this.img,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
      "status": status.name,
      "img": img,
      "user_id": userId,
    };
  }

  @override
  String toString() {
    return "Task(id: $id, title: $title, body: $body, status: ${status.name}, img: $img, userId: $userId)";
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map["id"],
      title: map["title"],
      body: map["body"],
      status: TaskStatus.values.firstWhere(
        // gets all the possible values in TaskStatus enum, then finds the first enum value that matches the condition
        (e) =>
            e.name ==
            map["status"], // compares the enum's name with the map's status value
        orElse:
            () =>
                TaskStatus
                    .planned, // if no match is found, it defaults to TaskStatus.planned
      ),
      img: map["img"],
      userId: map["user_id"],
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
