import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskGiverForm extends StatefulWidget {
  @override
  _TaskGiverFormState createState() => _TaskGiverFormState();
}

class _TaskGiverFormState extends State<TaskGiverForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _locationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Function to validate the deadline format (YYYY-MM-DD)
  bool _isValidDate(String date) {
    try {
      DateTime.parse(date); // Attempt to parse the date
      return true;
    } catch (e) {
      return false;
    }
  }

  // Function to validate the budget input is a number
  bool _isValidBudget(String budget) {
    return double.tryParse(budget) != null;
  }

  void _submitForm() async {
    // Validate if all fields are filled
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _deadlineController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    // Validate if budget is a valid number
    if (!_isValidBudget(_budgetController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid budget (must be a number).'),
      ));
      return;
    }

    // Validate the deadline format (YYYY-MM-DD)
    if (!_isValidDate(_deadlineController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid deadline in YYYY-MM-DD format.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Ensure the data passed to Firestore is correct and only happens if validation is passed
        await FirebaseFirestore.instance.collection('tasks').add({
          'title': _titleController.text, 
          'description': _descriptionController.text,
          'budget': double.parse(_budgetController.text), // Store as a number
          'deadline': Timestamp.fromDate(DateTime.parse(_deadlineController.text)),
          'location': _locationController.text,
          'postedBy': user.uid,
          'status': 'open', // Task status
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Task posted successfully!'),
        ));

        // Clear the form after posting
        _titleController.clear();
        _descriptionController.clear();
        _budgetController.clear();
        _deadlineController.clear();
        _locationController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to post task: $error'),
        ));
      }
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Task')),
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
              decoration: InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Show loading spinner when submitting
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Post Task'),
                  ),
          ],
        ),
      ),
    );
  }
}
