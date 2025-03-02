import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Settings"),
      ),
      body: Center(
        child: Text(
          "Settings Page (To be added)",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
