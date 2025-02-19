import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTaskPage extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _locationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitForm() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _budgetController.text.isNotEmpty &&
        _deadlineController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        // Add the task to the Firestore database
        final taskRef = await FirebaseFirestore.instance.collection('tasks').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'budget': _budgetController.text,
          'deadline': _deadlineController.text,
          'location': _locationController.text,
          'postedBy': user.uid,
          'status': 'open',
          'createdAt': Timestamp.now(),
        });

        // Send notification to all Taskers
        final taskersSnapshot = await FirebaseFirestore.instance.collection('users')
            .where('role', isEqualTo: 'Tasker')
            .get();

        for (var tasker in taskersSnapshot.docs) {
          FirebaseFirestore.instance.collection('notifications').add({
            'receiverId': tasker.id,
            'message': "New task posted: ${_titleController.text}",
            'timestamp': Timestamp.now(),
            'isRead': false,
          });
        }

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Task posted successfully!'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create a Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: 'Budget'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(labelText: 'Deadline'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Post Task'),
            ),
          ],
        ),
      ),
    );
  }
}
