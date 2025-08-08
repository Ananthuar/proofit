import 'dart:io';
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String title;
  final bool showCompleted;

  const TaskListScreen({
    super.key,
    required this.tasks,
    required this.title,
    required this.showCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((t) => showCompleted ? t['isCompleted'] == 1 : t['isCompleted'] == 0).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: filteredTasks.isEmpty
            ? Center(child: Text('No tasks found.'))
            : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(task['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(task['description']),
                      trailing: task['isCompleted'] == 1 && task['imagePath'] != null && task['imagePath'].isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: Image.file(
                                      File(task['imagePath']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.check_circle, color: Colors.green),
                            )
                          : Icon(Icons.radio_button_unchecked, color: Colors.orange),
                    ),
                  );
                },
              ),
      ),
    );
  }
}