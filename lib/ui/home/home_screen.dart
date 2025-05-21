import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? userPhotoUrl;

  @override
  void initState() {
    _init();
    _getUserProfile();
    super.initState();
  }

  void _init() async {
    final res = await repo.getAllTasks();
    setState(() {
      tasks = res;
    });
  }

  void _getUserProfile() async {
    // Get current user session
    final supabase = Supabase.instance.client;
    final User? user = supabase.auth.currentUser;
    
    if (user != null) {
      final userData = user.userMetadata;
      
      if (userData != null && userData['avatar_url'] != null) {
        setState(() {
          userPhotoUrl = userData['avatar_url'];
        });
      } else if (userData != null && userData['picture'] != null) {
        setState(() {
          userPhotoUrl = userData['picture'];
        });
      }
    }
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

  void _navigateToEditTask(Task task) async {
    var res = await context.pushNamed(
      Screen.editTask.name,
      pathParameters: {'id': task.id!.toString()}
    );
    if (res == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Task App"),
            Spacer(),
            // Profile image
            if (userPhotoUrl != null)
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(userPhotoUrl!),
                  ),
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: Icon(Icons.person, size: 20, color: Colors.grey.shade700),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child:
            tasks.isEmpty
                ? Center(child: Text("No tasks found"))
                : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => TaskCard (
                    task:tasks[index],
                    onClickItem: (task) => _navigateToEditTask(task),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onClickItem});
  final Function(Task) onClickItem;
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      child: GestureDetector(
        onTap: () => onClickItem(task),
        child: ListTile(
          leading: Icon(Icons.task),
          title: Text(task.title),
          subtitle: Text("Status: ${task.status.displayName}"),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}