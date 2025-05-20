class Task {
  int? id;
  final String title;
  final String body;
  final TaskStatus status; // by default it should be "Planned"
  final String img;

  static const name = "tasks";

  Task({
    this.id,
    required this.title,
    required this.body,
    this.status = TaskStatus.planned,
    this.img = "",
  });

  Task copy({
    int? id,
    String? title,
    String? body,
    TaskStatus? status,
    String? img,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      img: img ?? this.img,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
      "status": status.name,
      "img": img,
    };
  }

  @override
  String toString() {
    return "Task(id: $id, title: $title, body: $body, status: ${status.name}, img: $img)";
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map["id"],
      title: map["title"],
      body: map["body"],
      status: TaskStatus.values.firstWhere( // gets all the possible values in TaskStatus enum, then finds the first enum value that matches the condition
        (e) => e.name == map["status"], // compares the enum's name with the map's status value
        orElse: () => TaskStatus.planned, // if no match is found, it defaults to TaskStatus.planned
      ),
      img: map["img"],
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
}


