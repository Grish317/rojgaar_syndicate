import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskerProfilePage extends StatefulWidget {
  final String userId;

  TaskerProfilePage({required this.userId});

  @override
  _TaskerProfilePageState createState() => _TaskerProfilePageState();
}

class _TaskerProfilePageState extends State<TaskerProfilePage> {
  String? _imageUrl;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Add controllers for editable fields
  TextEditingController nameController = TextEditingController();
  TextEditingController skillsController = TextEditingController(); // Add skills controller
  TextEditingController educationController = TextEditingController(); // Add education controller

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadProfileData();
  }

  // Load the profile image URL from Firestore
  Future<void> _loadProfileImage() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>? ?? {};
        setState(() {
          _imageUrl = data['profilePicture']; // Assuming profile picture URL is stored in Firestore
        });
      } else {
        print("Profile not found.");
      }
    } catch (e) {
      print("Failed to load profile image: $e");
    }
  }

  // Load the profile data into the controllers
  Future<void> _loadProfileData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    var data = snapshot.data() as Map<String, dynamic>? ?? {};
    setState(() {
      nameController.text = data['name'] ?? '';
      skillsController.text = (data['skills'] as List<dynamic>?)?.join(', ') ?? '';
      educationController.text = data['education'] ?? '';
    });
  }

  // Pick image from gallery and upload to Firebase Storage
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadProfilePicture();
    }
  }

  // Upload profile picture to Firebase Storage and update Firestore with the URL
  Future<void> _uploadProfilePicture() async {
    if (_profileImage != null) {
      try {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${widget.userId}.jpg');
        await storageRef.putFile(_profileImage!);

        // Get the download URL of the uploaded image
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'profilePicture': downloadUrl,
        });

        // Update the UI with the new image URL
        setState(() {
          _imageUrl = downloadUrl;
        });
      } catch (e) {
        print("Failed to upload image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tasker Profile")),
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

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage, // Open gallery when tapped
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/default_profile_picture.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 10),
                // Editable Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Edit Name"),
                ),
                SizedBox(height: 10),
                // Editable Skills
                TextField(
                  controller: skillsController,
                  decoration: InputDecoration(labelText: "Edit Skills (comma-separated)"),
                ),
                SizedBox(height: 10),
                // Editable Education
                TextField(
                  controller: educationController,
                  decoration: InputDecoration(labelText: "Edit Education"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String updatedName = nameController.text;
                    List<String> updatedSkills = skillsController.text.split(',').map((skill) => skill.trim()).toList();
                    String updatedEducation = educationController.text;

                    // Update Firestore with the new values
                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'name': updatedName,
                      'skills': updatedSkills,
                      'education': updatedEducation,
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
