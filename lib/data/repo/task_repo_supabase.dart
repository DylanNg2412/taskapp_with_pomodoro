import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tomato_task/data/model/task.dart';

class TaskRepoSupabase {
  static final TaskRepoSupabase _instance = TaskRepoSupabase._init();

  TaskRepoSupabase._init();
  factory TaskRepoSupabase() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> addTask(Task task) async {
    await supabase.from('tasks').insert(task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final resp = await supabase
        .from('tasks')
        .select()
        .order('id', ascending: true);
    return resp.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task> getTaskById(int id) async {
    final resp = await supabase.from('tasks').select().eq('id', id).single();
    return Task.fromMap(resp);
  }

  Future<void> updateTask(Task task) async {
    final updatedMap = task.toMap();

    updatedMap['completed_at'] = task.completedAt?.toIso8601String();
    await supabase
        .from('tasks')
        .update(task.toMap())
        .eq('id', task.id!)
        .eq('user_id', task.userId!);
  }

  Future<void> deleteTask(int id, String userId) async {
    await supabase.from('tasks').delete().eq('id', id).eq('user_id', userId);
  }

  Future<List<Task>> getCompletedTasksByUser(String userId) async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);
    return response.map((json) => Task.fromMap(json)).toList();
  }
}
