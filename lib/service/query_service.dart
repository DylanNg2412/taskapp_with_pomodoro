import 'package:tomato_task/data/model/task.dart';
import 'package:tomato_task/data/model/task_status.dart';

List<Task> filterTasks({
  required List<Task> allTasks,
  required List<TaskStatus> statuses,
  required String searchQuery,
  required String sortBy,
}) {
  var filtered =
      allTasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
                statuses.contains(task.status),
          )
          .toList();

  if (sortBy == 'Status') {
    filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
  }

  if (sortBy == 'Title') {
    filtered.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
  }

  if (sortBy == 'Priority') {
    filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  return filtered;
}
