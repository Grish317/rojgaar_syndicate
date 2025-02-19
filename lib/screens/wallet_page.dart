import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:getwidget/getwidget.dart';

class WalletPage extends StatefulWidget {
  final String role; // Accept role as a parameter

  const WalletPage({super.key, required this.role}); // Constructor

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double _taskerBalance = 150.0; // Dummy balance for Tasker

  // Function to launch eSewa Payment Page
  Future<void> _openEsewaPayment() async {
    const esewaUrl = "https://esewa.com.np/#/home"; // eSewa URL for payment
    if (await canLaunch(esewaUrl)) {
      await launch(esewaUrl);
    } else {
      print("Could not launch eSewa URL");
    }
  }

  // Simulate Adding Funds After eSewa Payment (Only for Tasker)
  void _addFunds(double amount) {
    setState(() {
      _taskerBalance += amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funds added! New balance: Rs. $_taskerBalance')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet - ${widget.role}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.role == "Tasker"
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Using GFCard for the Tasker Wallet
                  GFCard(
                    boxFit: BoxFit.cover,
                    image: Image.asset("assets/wallet.png", fit: BoxFit.cover),
                    title: GFListTile(
                      avatar: Icon(Icons.account_balance_wallet, color: Colors.blue),
                      title: Text("Tasker Wallet"),
                      subTitle: Text("Balance: Rs. $_taskerBalance"),
                    ),
                    buttonBar: GFButtonBar(
                      children: <Widget>[
                        GFButton(
                          onPressed: _openEsewaPayment,
                          text: "Add Funds",
                          icon: Icon(Icons.payment, color: Colors.white),
                          color: GFColors.PRIMARY,
                        ),
                        GFButton(
                          onPressed: () => _addFunds(100), // Simulate adding Rs. 100
                          text: "Simulate Rs. 100 Add",
                          icon: Icon(Icons.add, color: Colors.white),
                          color: GFColors.SUCCESS,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: ElevatedButton(
                  onPressed: _openEsewaPayment,
                  child: Text('Pay via eSewa'),
                ),
              ),
      ),
    );
  }
}
