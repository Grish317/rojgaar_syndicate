import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  // Fetch the task details from Firestore to pre-fill the form
  void _loadTaskDetails() async {
  final taskDoc = await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).get();

  if (taskDoc.exists) {
    String taskUserId = taskDoc['userId'];

    // Check if the current user is the creator of the task
    if (taskUserId == FirebaseAuth.instance.currentUser!.uid) {
      _titleController.text = taskDoc['title'];
      _locationController.text = taskDoc['location'];
      _budgetController.text = taskDoc['budget'].toString();
      _deadlineController.text = taskDoc['deadline'].toDate().toString().split(' ')[0]; // Format date
    } else {
      // If the task does not belong to the current user, deny access
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are not authorized to edit this task.")));
      Navigator.pop(context);
    }
  }
}


  // Save edited task details
  void _saveTask() async {
  try {
    // Convert budget to string explicitly if it's not already
    String budget = _budgetController.text.trim(); // You can add extra validation if needed
    
    // For deadline, ensure it's in the correct string format
    String deadline = _deadlineController.text.trim(); 

    // Save the task details without validating budget and deadline
    await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update({
      'title': _titleController.text,
      'location': _locationController.text,
      'budget': budget,  // Save budget as string
      'deadline': deadline,  // Save deadline as string
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task updated successfully!")));
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: 'Budget'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
