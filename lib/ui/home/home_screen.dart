import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/navigation/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = TaskRepoSupabase();
  var tasks = <Task>[];

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    final res = await repo.getAllTasks();
    setState(() {
      tasks = res;
    });
  }

  void _refresh() async {
    final res = await repo.getAllTasks();
    setState(() {
      tasks = res;
    });
  }

  void _navigateToAddTask() async {
    var res = await context.pushNamed(Screen.addTask.name);
    if (res == true) {
      _refresh();
    }
  }

  // final List<Map<String, String>> tasks = [
  //   {
  //     'title': 'Read Flutter Guide',
  //     'status': 'Planned',
  //   },
  //   {
  //     'title': 'Work on Pomodoro UI',
  //     'status': 'In Progress',
  //   },
  //   {
  //     'title': 'Submit Proposal',
  //     'status': 'Completed',
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task App")),
      body: SafeArea(
        child:
            tasks.isEmpty
                ? Center(child: Text("No tasks found"))
                : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.task),
                        title: Text(task.title),
                        subtitle: Text("Status: ${task.status.displayName}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: Icon(Icons.add),
      ),
    );
  }
}
