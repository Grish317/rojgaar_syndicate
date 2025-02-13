import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskSearchPage extends StatefulWidget {
  final Function(String) onSearch;  // Callback to return search query

  TaskSearchPage({Key? key, required this.onSearch}) : super(key: key);

  @override
  _TaskSearchPageState createState() => _TaskSearchPageState();
}

class _TaskSearchPageState extends State<TaskSearchPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;  
                });
                widget.onSearch(searchQuery); // Pass search query back to HomePage
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  
                  .where('title', isGreaterThanOrEqualTo: searchQuery)
                  .where('title', isLessThan: searchQuery + 'z')
                  .snapshots(),
              builder: (ctx, taskSnapshot) {
                if (taskSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final taskDocs = taskSnapshot.data!.docs;
                return ListView.builder(
                  itemCount: taskDocs.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(taskDocs[index]['title']),
                      subtitle: Text('Location: ${taskDocs[index]['location']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}