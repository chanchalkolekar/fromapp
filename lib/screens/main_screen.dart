import 'package:flutter/material.dart';
import 'ema_watch_screen.dart'; // Import your EMA Watch Screen
import 'form_screen.dart'; // Import your Form Screen

class MainScreen extends StatefulWidget {
  final int initialIndex; // Add initialIndex parameter

  MainScreen({this.initialIndex = 0}); // Default value is 0 (EMA Watch Screen)

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    EmaWatchScreen(),
    // EMA Watch Screen
    FormScreen(),
    // Form Screen
    Center(child: Text('Another Screen Content')),
    // Placeholder for another screen
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the default screen index
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected screen index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BUY / SELL RATE ENTRY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue, // Updated background color
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Image.asset(
                  'assets/Rate form_transparent-.png', // Path to your image
                  width: 100, // Adjust width
                  height: 100, // Adjust height
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.black),
              title: Text('EMA Watch'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _onItemTapped(0); // Navigate to EMA Watch Screen
              },
            ),
            ListTile(
              leading: Icon(Icons.format_list_bulleted, color: Colors.black),
              title: Text('Form Screen'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1); // Navigate to Form Screen
              },
            ),
            ListTile(
              leading: Icon(Icons.more_horiz, color: Colors.black),
              title: Text('Another Screen'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2); // Navigate to Another Screen
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex], // Show the selected screen
    );
  }
}
