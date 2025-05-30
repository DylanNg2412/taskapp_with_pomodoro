import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/model/task_prio.dart';
import 'package:taskapp_with_pomodoro/data/model/task_status.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/navigation/navigation.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:taskapp_with_pomodoro/service/query_service.dart';

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
    return filterTasks(
      allTasks: tasks,
      statuses: statuses,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  Widget _taskList(
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              "My Tasks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    userPhotoUrl != null
                        ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(userPhotoUrl!),
                            ),
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      height: 50,
                      child: SearchBar(
                        autoFocus: false,
                        controller: _searchController,
                        hintText: "Search tasks...",
                        leading: Icon(Icons.search, color: Colors.grey[600]),
                        trailing: [
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                searchQuery = '';
                              });
                            },
                          ),
                        ],
                        backgroundColor: WidgetStateProperty.all(
                          Colors.grey[100],
                        ),
                        elevation: WidgetStateProperty.all(1),
                        onSubmitted: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.sort, color: Colors.grey[600], size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Sort by:",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            value: sortBy,
                            isExpanded: true,
                            underline: SizedBox(),
                            items: [
                              DropdownMenuItem(
                                value: "Default",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 8),
                                    Text("Default"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Title",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.title,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 8),
                                    Text("Title"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Status",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 8),
                                    Text("Status"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Priority",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 8),
                                    Text("Priority"),
                                  ],
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tabs Section
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.schedule, size: 18),
                                SizedBox(width: 6),
                                Text("Ongoing"),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 18),
                                SizedBox(width: 6),
                                Text("Completed"),
                              ],
                            ),
                          ),
                        ],
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        indicatorWeight: 3,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _taskList(
                            context,
                            statuses: [
                              TaskStatus.planned,
                              TaskStatus.inProgress,
                            ],
                          ),
                          _taskList(
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _navigateToAddTask,
          backgroundColor: Colors.blue,
          elevation: 1,
          child: Icon(Icons.add, size: 28, color: Colors.white),
        ),
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
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: task.priority.priorityColor, width: 5),
        ),
      ),
      child: GestureDetector(
        onTap: () => onClickItem(task),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: task.status.taskBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              task.status.taskIcon,
              color: task.status.taskBgColor,
              size: 24,
            ),
          ),
          title: Text(
            task.title.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  "Status: ${task.status.displayName}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.priority.priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: task.priority.priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
