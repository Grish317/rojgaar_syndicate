import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_task.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String taskId;
  final String role;
  final String postedBy;
  final Timestamp createdAt;

  const TaskTile({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.taskId,
    required this.role,
    required this.postedBy,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Location: $location\nBudget: $price"),
        trailing: role == 'Tasker'
            ? ElevatedButton(
                onPressed: () {
                  _applyForTask(context, taskId, title, postedBy);
                },
                child: const Text("Apply"),
              )
            : ElevatedButton(
                onPressed: () {
                  _showManageOptions(context, taskId, postedBy);
                },
                child: const Text("Manage"),
              ),
      ),
    );
  }

  void _applyForTask(BuildContext context, String taskId, String title, String postedBy) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('task_requests').add({
        'taskId': taskId,
        'taskerId': user.uid,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverId': postedBy,
        'senderId': user.uid,
        'message': "Someone applied for your task: $title",
        'timestamp': Timestamp.now(),
        'isRead': false,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Applied for task: $title")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to apply for tasks")),
      );
    }
  }

  void _showManageOptions(BuildContext context, String taskId, String postedBy) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to manage tasks")),
      );
      return;
    }

    if (currentUser.uid != postedBy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot manage this task.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Manage Task"),
        content: Text("What would you like to do with this task?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTaskPage(taskId: taskId)),
              );
            },
            child: Text("Edit"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Task deleted successfully!")),
              );
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
