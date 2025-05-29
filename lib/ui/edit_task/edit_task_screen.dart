import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/model/task_status.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/service/storage_service.dart';
import 'package:taskapp_with_pomodoro/ui/pomodoro/pomodoro_screen.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.id});
  final String id;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final repo = TaskRepoSupabase();
  final storageService = StorageService();
  final supabase = Supabase.instance.client;

  List<Task> tasks = [];
  Task? task;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String imageUrl = "";
  String? fileName;
  Uint8List? bytes;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    task = await repo.getTaskById((int.parse(widget.id)));
    _loadImage();
    _titleController.text = task?.title ?? "";
    _bodyController.text = task?.body ?? "";
  }

  void _loadImage() async {
    final imageBytes = await storageService.getImage(task!.img);
    setState(() {
      bytes = imageBytes;
      fileName = task!.img;
    });
  }

  void _editTask() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      return _showSnackbar("Fields cannot be empty");
    }

    if (task == null) {
      _showSnackbar("Something went wrong");
      return;
    }

    if (fileName != null && bytes != null) {
      await storageService.uploadImage(fileName!, bytes!);
    }

    await repo.updateTask(
      task!.copy(
        title: _titleController.text,
        body: _bodyController.text,
        img: fileName ?? "",
        userId: supabase.auth.currentUser!.id,
        completedAt: DateTime.now()
      ),
    );

    if (!mounted) return;
    _showSnackbar("Task edited successfully");
    Navigator.pop(context, true);
  }

  void _deleteTask() async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Delete Task'),
                content: Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldDelete) return;

    if (task != null) {
      try {
        await repo.deleteTask(task!.id!, supabase.auth.currentUser!.id);
        if (!mounted) return;
        _showSnackbar("Task deleted successfully");
        context.pop(true);
      } catch (e) {
        if (!mounted) return;
        _showSnackbar(
          "Failed to delete task: ${e.toString()}",
          isSuccess: false,
        );
        debugPrint("Delete task error: $e");
      }
    } else {
      _showSnackbar("Cannot delete: Task not found", isSuccess: false);
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final imageBytes = await file.readAsBytes();
      setState(() {
        fileName = result.files.single.name;
        bytes = imageBytes;
      });
    }
  }

  void _startPomodoro() async {
    if (task == null) {
      _showSnackbar("No task selected for Pomodoro");
      return;
    }

    final updated = task!.copy(status: TaskStatus.inProgress);
    await repo.updateTask(updated);

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PomodoroScreen(task: updated)),
    );

    if (result == true) {
      final refreshed = await repo.getTaskById(task!.id!);
      if (mounted) {
        setState(() {
          task = refreshed;
          _titleController.text = task!.title;
          _bodyController.text = task!.body;
          _loadImage(); // reload image if needed
        });
      }
    }
  }

  void _showSnackbar(String msg, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter new title...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: "Enter new body...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text("Status: ${task?.status.displayName ?? "Unknown"}"),
              SizedBox(height: 16),
              if (bytes != null)
                Image.memory(
                  bytes!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              Text(fileName ?? "Upload image"),
              SizedBox(height: 16),
              GestureDetector(onTap: _pickFile, child: Icon(Icons.add_a_photo)),
              SizedBox(height: 24),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _editTask,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Save"),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _deleteTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Delete"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startPomodoro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Start Pomodoro"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
