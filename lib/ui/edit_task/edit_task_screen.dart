import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/service/storage_service.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.id});
  final String id;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final repo = TaskRepoSupabase();
  final storageService = StorageService();
  List<Task> tasks = [];
  late Task? task;

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
      return _showSnackBar("Fields cannot be empty");
    }

    if (task == null) {
      _showSnackBar("Something went wrong");
    }

    if (fileName != null && bytes != null) {
      await storageService.uploadImage(fileName!, bytes!);
    }

    await repo.updateTask(
      task!.copy(
        title: _titleController.text,
        body: _bodyController.text,
        img: fileName ?? "",
      ),
    );

    if (!mounted) return;
    _showSnackBar("Task edited successfully");
    context.pop(true);
  }
  
  void _deleteTask() async {
    // Show confirmation dialog before deleting
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
    ) ?? false;
    
    // If user canceled, return early
    if (!shouldDelete) return;
    
    // Delete the task from the database
    if (task != null) {
      try {
        await repo.deleteTask(task!.id!);
        if (!mounted) return;
        _showSnackBar("Task deleted successfully");
        // Navigate back with result
        context.pop(true);
      } catch (e) {
        _showSnackBar("Failed to delete task: ${e.toString()}");
      }
    } else {
      _showSnackBar("Cannot delete: Task not found");
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

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
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
                controller: _bodyController, // Fixed: was using _titleController twice
                decoration: InputDecoration(
                  hintText: "Enter new body...", // Fixed: incorrect hint text
                  border: OutlineInputBorder(),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _editTask,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Save Changes"),
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
                      ),
                      child: Text("Delete Task"),
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