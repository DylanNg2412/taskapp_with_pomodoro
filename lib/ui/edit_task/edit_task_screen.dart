import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/model/task_prio.dart';
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
  TaskPriority? _selectedPriority;
  String imageUrl = "";
  String? fileName;
  Uint8List? bytes;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    task = await repo.getTaskById(int.parse(widget.id));
    _titleController.text = task?.title ?? "";
    _bodyController.text = task?.body ?? "";
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _loadImage();
  }

  void _loadImage() async {
    final imageBytes = await storageService.getImage(task!.img);
    setState(() {
      bytes = imageBytes;
      fileName = task!.img;
    });
  }

  void _editTask() async {
    if (_titleController.text.isEmpty) {
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
        body: _bodyController.text.isEmpty ? null : _bodyController.text,
        priority: _selectedPriority,
        img: fileName ?? "",
        userId: supabase.auth.currentUser!.id,
        completedAt: DateTime.now(),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Edit Task",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete Task',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    const Text(
                      "Task Title",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Enter new title...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(Icons.title, color: Colors.grey[400]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Priority",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<TaskPriority>(
                        value: _selectedPriority,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.flag,
                            color: _selectedPriority?.priorityColor,
                          ),
                        ),
                        items:
                            TaskPriority.values.map((priority) {
                              return DropdownMenuItem<TaskPriority>(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: priority.priorityColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('${priority.displayName} Priority'),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (TaskPriority? newValue) {
                          setState(() {
                            _selectedPriority = newValue!;
                          });
                        },
                        dropdownColor: Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description Field
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter new description...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Icon(
                            Icons.description,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Image Section
                    const Text(
                      "Attachment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (bytes != null) ...[
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.memory(
                                bytes!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => bytes = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red[400],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (fileName != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fileName!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],

                    // Add/Change Photo Button
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              bytes != null ? Icons.edit : Icons.add_a_photo,
                              color: Colors.grey[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bytes != null ? "Change Photo" : "Add Photo",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Actions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Pomodoro Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startPomodoro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.green.withValues(alpha: 0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Start Pomodoro",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Save and Delete Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _editTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _showDeleteConfirmation(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            child: const Icon(Icons.delete, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text("Delete Task"),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete this task? This action cannot be undone.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
