import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_task_page.dart';
import 'task_search.dart';
import 'edit_task.dart';
import 'task_tile.dart';
import 'tasker_profile.dart';
import 'task_giver_profile.dart';
import 'notifications_page.dart';
import 'voice_task_search.dart';
import 'package:intl/intl.dart';
import 'wallet_page.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("Rojgaar - ${widget.role} Dashboard"),
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
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
    IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
      },
    ),
    // **Wallet Button**
    IconButton(
      icon: Icon(Icons.account_balance_wallet),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletPage(role: widget.role)),
        );
      },
    ),
    // **Profile Button**
    IconButton(
      icon: Icon(Icons.account_circle),
      onPressed: () {
        _navigateToProfile();
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
                price: taskDocs[index]['budget'],
                taskId: taskDocs[index].id,
                role: widget.role,
                postedBy: taskDocs[index]['postedBy'],
                createdAt: taskDocs[index]['createdAt'],
              );
            },
          );
        },
      ),

      floatingActionButton: widget.role == "Task Giver"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTaskPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Function to navigate to the correct profile page based on user role
  void _navigateToProfile() {
  String normalizedRole = widget.role.toLowerCase().replaceAll(' ', '_');

  if (normalizedRole == 'tasker') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskerProfilePage(userId: userId)),
    );
  } else if (normalizedRole == 'task_giver') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskGiverProfilePage(userId: userId)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User role not found!")),
    );
  }
}

}
