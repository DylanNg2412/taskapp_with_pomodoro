import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/navigation/navigation.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = TaskRepoSupabase();
  var tasks = <Task>[];
  String? userPhotoUrl;
  String searchQuery = '';
  String sortBy = 'Default';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    if (mounted) {
      context.pushReplacementNamed(Screen.login.name);
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
      pathParameters: {'id': task.id!.toString()},
    );
    if (res == true) {
      _refresh();
    }
  }

  List<Task> _getTasksByStatus(List<TaskStatus> statuses) {
    var filtered =
        tasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) &&
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

    return filtered;
  }

  Widget _buildTaskList(
    BuildContext context, {
    required List<TaskStatus> statuses,
  }) {
    final filtered = _getTasksByStatus(statuses);

    if (filtered.isEmpty) {
      return Center(child: Text("No tasks found"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder:
          (context, index) => TaskCard(
            task: filtered[index],
            onClickItem: (task) => _navigateToEditTask(task),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Task App"),
            Spacer(),
            GestureDetector(
              onTap: _showLogoutDialog,
              child:
                  userPhotoUrl != null
                      ? Container(
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
                      : Container(
                        width: 32,
                        height: 32,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AnimSearchBar(
                      width: MediaQuery.of(context).size.width * 0.75,
                      textController: _searchController,
                      helpText: "Search tasks...",
                      autoFocus: false,
                      onSuffixTap: () {
                        setState(() {
                          _searchController.clear();
                          searchQuery = '';
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    icon: Icon(Icons.list),
                    value: sortBy,
                    items: [
                      DropdownMenuItem(
                        value: 'Default',
                        child: Row(
                          children: [SizedBox(width: 10), Text('Default')],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Title',
                        child: Row(
                          children: [SizedBox(width: 10), Text('Title')],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Status',
                        child: Row(
                          children: [SizedBox(width: 10), Text('Status')],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          sortBy = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [Tab(text: 'Ongoing'), Tab(text: 'Completed')],
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTaskList(
                            context,
                            statuses: [
                              TaskStatus.planned,
                              TaskStatus.inProgress,
                            ],
                          ),
                          _buildTaskList(
                            context,
                            statuses: [TaskStatus.completed],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      color: Colors.white,
      margin: EdgeInsets.all(10),
      elevation: 4,
      child: GestureDetector(
        onTap: () => onClickItem(task),
        child: ListTile(
          leading: Icon(task.status.taskIcon, color: task.status.taskBgColor),
          title: Text(task.title.toUpperCase()),
          subtitle: Text("Status: ${task.status.displayName}"),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
