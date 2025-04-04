import 'package:flutter/material.dart';
import 'read.dart';
import 'control.dart';


class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 1; // Default to 'Control' page

  // Pages to switch between
  final List<Widget> _pages = [
    ReadPage(),
    ControlPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Read Page' : 'Control Options'),
        backgroundColor: const Color.fromRGBO(50, 85, 131, 1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        color: const Color.fromRGBO(50, 85, 131, 1),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: Text(
                'Read',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.yellow : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Text(
                'Control',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.yellow : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
