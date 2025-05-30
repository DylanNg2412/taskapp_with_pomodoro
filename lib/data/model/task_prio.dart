import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityToString on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return "Low";
      case TaskPriority.medium:
        return "Medium";
      case TaskPriority.high:
        return "High";
    }
  }

  Color get priorityColor {
    switch (this) {
      case TaskPriority.low:
        return Colors.green[400]!;
      case TaskPriority.medium:
        return Colors.orange[400]!;
      case TaskPriority.high:
        return Colors.red[400]!;
    }
  }
}
