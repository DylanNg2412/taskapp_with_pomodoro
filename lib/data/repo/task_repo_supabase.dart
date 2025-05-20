import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';

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
    await supabase.from('tasks').update(task.toMap()).eq('id', task.id!);
  }

  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
