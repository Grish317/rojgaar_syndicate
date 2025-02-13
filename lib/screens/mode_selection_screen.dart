import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void selectRole(BuildContext context, String role) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role, // Store selected role in Firestore
      }, SetOptions(merge: true)); // Merge to avoid overwriting

      // Navigate to HomePage with role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(role: role)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => selectRole(context, "Task Giver"),
              child: const Text("Task Giver"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => selectRole(context, "Tasker"),
              child: const Text("Tasker"),
            ),
          ],
        ),
      ),
    );
  }
}
