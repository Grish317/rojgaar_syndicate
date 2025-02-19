import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatefulWidget {
  final String role; // Add this

  const WalletPage({super.key, required this.role}); // Modify constructor

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double _taskerBalance = 150.0; // Dummy balance for Tasker
  double _taskGiverBalance = 500.0; // Dummy balance for Task Giver

  // Function to launch eSewa Payment Page
  Future<void> _openEsewaPayment(String userType) async {
    const esewaUrl = "https://esewa.com.np/#/home"; // eSewa URL for payment
    if (await canLaunch(esewaUrl)) {
      await launch(esewaUrl);
    } else {
      print("Could not launch eSewa URL");
    }
  }

  // Simulate Adding Funds After eSewa Payment
  void _addFunds(String userType, double amount) {
    setState(() {
      if (userType == "Tasker") {
        _taskerBalance += amount;
      } else {
        _taskGiverBalance += amount;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funds added! New balance: Rs. ${userType == "Tasker" ? _taskerBalance : _taskGiverBalance}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet - ${widget.role}')), // Display role in title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasker Wallet Balance: Rs. $_taskerBalance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _openEsewaPayment("Tasker"),
              child: Text('Add Funds via eSewa (Tasker)'),
            ),
            ElevatedButton(
              onPressed: () => _addFunds("Tasker", 100), // Simulate adding Rs. 100
              child: Text('Simulate Rs. 100 Add (Tasker)'),
            ),

            SizedBox(height: 40),

            Text('Task Giver Wallet Balance: Rs. $_taskGiverBalance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _openEsewaPayment("Task Giver"),
              child: Text('Pay via eSewa (Task Giver)'),
            ),
            ElevatedButton(
              onPressed: () => _addFunds("Task Giver", 200), // Simulate adding Rs. 200
              child: Text('Simulate Rs. 200 Add (Task Giver)'),
            ),
          ],
        ),
      ),
    );
  }
}
