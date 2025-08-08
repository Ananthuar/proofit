import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../backend_function/db_helper.dart';
import '../backend_function/image_verifier.dart';
import 'add_task_screen.dart';
import 'task_list_screen.dart';
import 'notification_screen.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> _tasks = [];
  int completedCount = 0;
  int pendingCount = 0;
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await DBHelper().getTasks();
    setState(() {
      _tasks = data;
      completedCount = _tasks.where((t) => t['isCompleted'] == 1).length;
      pendingCount = _tasks.where((t) => t['isCompleted'] == 0).length;
      _notifications = _tasks
          .where((t) => t['isCompleted'] == 0)
          .map<String>((t) => 'Pending: ${t['title']} - ${t['description']}')
          .toList();
    });
  }

  Future<void> _addTask(String title, String description) async {
    await DBHelper().insertTask({'title': title, 'description': description, 'isCompleted': 0, 'imagePath': ''});
    await _loadTasks();
  }

  Future<void> _completeTaskWithImage(int id) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final task = _tasks.firstWhere((t) => t['id'] == id);
      final description = task['description'] ?? '';
      final verified = ImageVerifier.verify(description, pickedFile.path);

      if (verified) {
        await DBHelper().updateTask(id, 1, imagePath: pickedFile.path);
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image verified! Task marked as completed.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(12),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image does not match the task description. Please upload a valid proof.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(12),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image is required to complete the task.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    await DBHelper().deleteTask(id);
    await _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _clearAllTasks() async {
    final incompleteTasks = _tasks.where((t) => t['isCompleted'] != 1 || t['imagePath'] == null || t['imagePath'].isEmpty).toList();
    if (incompleteTasks.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All tasks must be completed with image before clearing.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
      return;
    }
    await DBHelper().clearTasks();
    await _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All tasks cleared'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Tasks'),
        content: Text('Are you sure you want to delete all tasks? Only tasks completed with image can be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllTasks();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(notifications: _notifications),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ProofIt',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _showClearAllDialog,
          ),
        ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskListScreen(
                            tasks: _tasks,
                            title: 'Tasks Completed',
                            showCompleted: true,
                          ),
                        ),
                      );
                    },
                    child: _buildStatCard('Tasks Completed', completedCount.toString(), Colors.blue),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskListScreen(
                            tasks: _tasks,
                            title: 'Pending Tasks',
                            showCompleted: false,
                          ),
                        ),
                      );
                    },
                    child: _buildStatCard('Pending Tasks', pendingCount.toString(), Colors.orange),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Your Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(task['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(task['description']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (task['isCompleted'] == 0)
                                  IconButton(
                                    icon: Icon(Icons.camera_alt, color: Colors.green),
                                    onPressed: () => _completeTaskWithImage(task['id']),
                                  ),
                                if (task['isCompleted'] == 1 && task['imagePath'] != null && task['imagePath'].isNotEmpty)
                                  GestureDetector(
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
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    if (task['isCompleted'] == 1 && task['imagePath'] != null && task['imagePath'].isNotEmpty) {
                                      await _deleteTask(task['id']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Complete the task with image before deletion.'),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          margin: EdgeInsets.all(12),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
            if (result != null) {
              await _addTask(result['title'], result['description']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Task Added: ${result['title']} - ${result['description']}"),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(12),
                ),
              );
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}