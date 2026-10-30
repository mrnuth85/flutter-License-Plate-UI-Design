import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: NotificationsPage(),
  ));
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C12F3),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              color: Color(0xFFDDDDDD),
              size: 120,
            ),
            SizedBox(height: 16),
            Text(
              "Your notifications will appear here.",
              style: TextStyle(fontSize: 14, color: Color(0xFFDDDDDD)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}