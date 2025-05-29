import 'package:flutter/animation.dart';
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
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
