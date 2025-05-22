import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskapp_with_pomodoro/data/model/task.dart';
import 'package:taskapp_with_pomodoro/data/repo/task_repo_supabase.dart';
import 'package:taskapp_with_pomodoro/service/storage_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final repo = TaskRepoSupabase();
  final storageService = StorageService();
  final supabase = Supabase.instance.client;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _titleError;
  String? _bodyError;
  String? fileName;
  Uint8List? bytes;

  void _addTask() async {
    if (_titleController.text.isEmpty) {
      setState(() {
        _titleError = "Title cannot be empty";
      });
      return;
    }

    if (_bodyController.text.isEmpty) {
      setState(() {
        _bodyError = "Body cannot be empty";
      });
      return;
    }

    if (fileName != null && bytes != null) {
      await storageService.uploadImage(fileName!, bytes!);
    }

    await repo.addTask(
      Task(
        title: _titleController.text,
        body: _bodyController.text,
        img: fileName ?? "",
        userId: supabase.auth.currentUser!.id,
      ),
    );
    _showSnackbar("Task added successfully");
    if (!mounted) return;
    context.pop(true);
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      bytes = await file.readAsBytes();
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                onChanged:
                    (_) => setState(() {
                      _titleError = null;
                    }),
                decoration: InputDecoration(
                  hintText: "Enter title",
                  border: OutlineInputBorder(),
                  errorText: _titleError,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: "Enter description",
                  border: OutlineInputBorder(),
                  errorText: _bodyError,
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
              GestureDetector(onTap: _pickFile, child: Icon(Icons.add_a_photo)),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _addTask, child: Text("Add")),
            ],
          ),
        ),
      ),
    );
  }
}
