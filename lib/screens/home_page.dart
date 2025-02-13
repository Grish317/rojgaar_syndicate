import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_task_page.dart';
import 'task_search.dart';
import 'edit_task.dart';
import 'voice_task_search.dart'; // Import the voice search page
import 'package:intl/intl.dart'; // To format the date

class HomePage extends StatefulWidget {
  final String role; // Add role parameter

  const HomePage({super.key, required this.role}); // Modify constructor

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = ''; // Holds the current search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rojgaar - ${widget.role} Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Navigate to the TaskSearchPage for normal search
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskSearchPage(
                    onSearch: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {
              // Navigate to the VoiceSearchPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceSearchPage(
                    onSearch: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('tasks')
      .where('title', isGreaterThanOrEqualTo: searchQuery)
      .where('title', isLessThan: searchQuery + 'z')
      .snapshots(),
  builder: (ctx, taskSnapshot) {
    if (taskSnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (taskSnapshot.hasError) {
      return Center(child: Text("Error: ${taskSnapshot.error}"));
    }

    final taskDocs = taskSnapshot.data!.docs;
    return ListView.builder(
      itemCount: taskDocs.length,
      itemBuilder: (ctx, index) {
        return TaskTile(
          title: taskDocs[index]['title'],
          location: taskDocs[index]['location'],
          price: taskDocs[index]['budget'], // Use 'budget' instead of 'price'
          taskId: taskDocs[index].id,
          role: widget.role,
          postedBy: taskDocs[index]['postedBy'], // Corrected field name here
          createdAt: taskDocs[index]['createdAt'], // Added createdAt here
        );
      },
    );
  },
)
,

      floatingActionButton: widget.role == "Task Giver"
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to the CreateTaskPage when the Task Giver presses the button
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTaskPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null, // Taskers don't need to create tasks
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String location;
  final String price; // Change 'price' to 'budget' here
  final String taskId;
  final String role;
  final String postedBy;
  final Timestamp createdAt; // Added createdAt parameter

  const TaskTile({
    super.key,
    required this.title,
    required this.location,
    required this.price, // This should refer to 'budget'
    required this.taskId,
    required this.role,
    required this.postedBy,
    required this.createdAt, // Pass createdAt to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Location: $location\nBudget: $price"), // Change 'Price' to 'Budget' here
        trailing: role == 'Tasker'
            ? ElevatedButton(
                onPressed: () {
                  _applyForTask(context, taskId, title);
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
}


void _applyForTask(BuildContext context, String taskId, String title) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Add task request to Firestore (task_requests collection)
    await FirebaseFirestore.instance.collection('task_requests').add({
      'taskId': taskId,
      'taskerId': user.uid,
      'status': 'pending', // Request status
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Applied for task: $title")),
    );
  } else {
    // Prompt to sign in if user is not authenticated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please log in to apply for tasks")),
    );
  }
}

void _showManageOptions(BuildContext context, String taskId, String postedBy) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    // Prompt to sign in if user is not authenticated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please log in to manage tasks")),
    );
    return;
  }

  if (currentUser.uid != postedBy) {
    // If the current user is not the task creator, show an error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You cannot manage this task.")),
    );
    return;
  }

  // Show a dialog or bottom sheet with edit and delete options
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Manage Task"),
      content: Text("What would you like to do with this task?"),
      actions: [
        TextButton(
          onPressed: () {
            // Navigate to the edit page to modify the task
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskPage(taskId: taskId),
              ),
            );
          },
          child: Text("Edit"),
        ),
        TextButton(
          onPressed: () async {
            // Delete the task
            await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Task deleted successfully!")),
            );
            Navigator.pop(context); // Close the dialog
          },
          child: Text("Delete"),
        ),
        TextButton(
          onPressed: () {
            // Just close the dialog without any action
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
      ],
    ),
  );
}
