import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TaskGiverProfilePage extends StatefulWidget {
  final String userId;

  TaskGiverProfilePage({required this.userId});

  @override
  _TaskGiverProfilePageState createState() => _TaskGiverProfilePageState();
}

class _TaskGiverProfilePageState extends State<TaskGiverProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController postedTasksController = TextEditingController();
  File? _profileImage;
  String? profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${widget.userId}.jpg');
        await storageRef.putFile(_profileImage!);
        String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          profileImageUrl = downloadUrl;
        });
        // Save the URL to Firestore
        FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'profilePicture': downloadUrl,
        });
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Giver Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Profile not found"));
          }

          var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          var ratings = data['ratings'] is Map<String, dynamic> ? data['ratings'] as Map<String, dynamic> : {};
          double totalStars = (ratings['totalStars'] ?? 0).toDouble();
          double totalReviews = (ratings['totalReviews'] ?? 1).toDouble();
          double rating = totalStars / totalReviews;

          nameController.text = data['name'] ?? '';
          postedTasksController.text = (data['postedTasks'] as List<dynamic>?)?.join(', ') ?? '';
          profileImageUrl = data['profilePicture'];

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/placeholder.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 10),
                // Name
                Text("Name: ${data['name']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                // Posted Tasks
                Text("Posted Tasks: ${data['postedTasks']?.join(', ') ?? 'None'}"),
                SizedBox(height: 10),
                // Rating
                Text("Rating: ⭐ ${rating.toStringAsFixed(1)} (${ratings['totalReviews']} reviews)"),
                SizedBox(height: 20),

                // Task History Section
                Text("Task History:"),
                ...((data['postedTasks'] as List<dynamic>?)?.map<Widget>((task) => Text("• $task")).toList() ?? []),

                // Editing Section
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Edit Name"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: postedTasksController,
                  decoration: InputDecoration(labelText: "Edit Posted Tasks (comma-separated)"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String updatedName = nameController.text;
                    List<String> updatedTasks = postedTasksController.text.split(',').map((task) => task.trim()).toList();

                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'name': updatedName,
                      'postedTasks': updatedTasks,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated")));
                  },
                  child: Text("Save Changes"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
