import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTaskPage extends StatelessWidget {
  final String taskId;
  
  const EditTaskPage({Key? key, required this.taskId}) : super(key: key);

  // Function to update request status and notify tasker
  void _updateRequestStatus(String requestId, String taskerId, String newStatus, String title) async {
    await FirebaseFirestore.instance.collection('task_requests').doc(requestId).update({
      'status': newStatus,
    });

    // Notify Tasker
    FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': taskerId,
      'message': "Your application for '$title' was $newStatus",
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('tasks').doc(taskId).get(),
        builder: (ctx, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (taskSnapshot.hasError) {
            return Center(child: Text("Error: ${taskSnapshot.error}"));
          }

          final taskData = taskSnapshot.data!;
          final taskTitle = taskData['title'];
          final taskerId = taskData['postedBy']; // Assuming this is the tasker's ID (may vary)
          final requestId = taskData.id;

          return Column(
            children: [
              // Task details display
              ListTile(
                title: Text('Task Title: $taskTitle'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Change status to 'accepted'
                  _updateRequestStatus(requestId, taskerId, 'accepted', taskTitle);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task application accepted!')),
                  );
                },
                child: Text('Accept Application'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Change status to 'rejected'
                  _updateRequestStatus(requestId, taskerId, 'rejected', taskTitle);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task application rejected!')),
                  );
                },
                child: Text('Reject Application'),
              ),
            ],
          );
        },
      ),
    );
  }
}
