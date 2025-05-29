import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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