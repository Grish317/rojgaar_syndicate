import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // To format the date

class NotificationsPage extends StatelessWidget {
  // Function to create a new notification with default 'pending' status
  Future<void> createNotification(String receiverId, String message, String senderId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Add notification with 'pending' status
    await firestore.collection('notifications').add({
      'receiverId': receiverId,  // Tasker (Receiver of notification)
      'senderId': senderId,      // Task Giver (Sender of notification)
      'message': message,        // Message content
      'status': 'pending',       // Default status is 'pending'
      'timestamp': Timestamp.now(), // Timestamp of notification creation
      'isRead': false,           // Initially marked as unread
    });
  }

  // Function to update Firestore status and notify the tasker
  Future<void> updateStatus(String notificationId, String newStatus, String senderId, String message) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update the current notification status
    await firestore.collection('notifications').doc(notificationId).update({
      'status': newStatus,
    });

    // If declined, notify the tasker (sender)
    if (newStatus == "declined") {
      await firestore.collection('notifications').add({
        'receiverId': senderId,  // Tasker who applied
        'message': "Your request was declined: $message",
        'status': 'unread',  // Set as unread for the tasker
        'timestamp': Timestamp.now(),
        'senderId': FirebaseAuth.instance.currentUser?.uid,  // Sender is the current user
        'isRead': false,  // Initially mark as unread for the tasker
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return Center(child: Text("No notifications"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (ctx, index) {
              final notification = notifications[index];

              // Safely access fields with default values
              String message = notification['message'] ?? "No message";
              String status = notification['status'] ?? 'pending';
              String senderId = notification['senderId'] ?? '';
              Timestamp timestamp = notification['timestamp'];
              String formattedDate = DateFormat.yMMMd().format(timestamp.toDate());

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(message),
                  subtitle: Text(formattedDate),
                  trailing: status == "pending"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateStatus(notification.id, "accepted", senderId, message),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text("Accept"),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => updateStatus(notification.id, "declined", senderId, message),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: Text("Decline"),
                            ),
                          ],
                        )
                      : Text(status.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  onTap: () {
                    // Mark as read
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notification.id)
                        .update({'isRead': true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
