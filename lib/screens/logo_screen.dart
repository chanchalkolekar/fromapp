import 'package:flutter/material.dart';
import 'main_screen.dart'; // Import MainScreen
import 'dart:async';

class LogoScreen extends StatefulWidget {
  @override
  _LogoScreenState createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    // Timer for 5 seconds, then navigate to MainScreen
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainScreen(initialIndex: 1), // FormScreen as default screen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20), // Padding around the logo
          decoration: BoxDecoration(
            color: Colors.black, // Background color for logo container
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          child: Image.asset(
            'assets/Rate form_transparent-.png', // Your logo image
            width: 150, // Adjust size as needed
            height: 150, // Adjust size as needed
          ),
        ),
      ),
    );
  }
}
