import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Tasks')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('status', isEqualTo: 'open') // Show only open tasks
            .snapshots(),
        builder: (ctx, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final taskDocs = taskSnapshot.data!.docs;
          return ListView.builder(
            itemCount: taskDocs.length,
            itemBuilder: (ctx, index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(taskDocs[index]['title']),
                  subtitle: Text('Location: ${taskDocs[index]['location']}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await requestTask(taskDocs[index].id, user.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Applied for task")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please log in to apply for tasks")),
                        );
                      }
                    },
                    child: Text('Apply'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Function to request a task
  Future<void> requestTask(String taskId, String taskerId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('tasks').doc(taskId).update({
      "requests": FieldValue.arrayUnion([taskerId]) // Adds taskerId to the requests array
    });

    print("Task request sent!");

    Future<void> removeTaskRequest(String taskId, String taskerId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection('tasks').doc(taskId).update({
    "requests": FieldValue.arrayRemove([taskerId]) // Removes taskerId from requests array
  });

  print("Task request removed!");
}

  }
}
