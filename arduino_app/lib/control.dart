import 'dart:convert'; // Required for utf8 encoding
import 'package:flutter/material.dart';
import 'package:arduino_app/voice.dart'; // Import the voice page
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Required for Bluetooth connection

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  BluetoothConnection? connection; // Nullable connection
  bool _isConnected = false;  // Initially set to false

  @override
  void initState() {
    super.initState();
    // You can initialize the Bluetooth connection here or in the VoiceControlPage
  }

  // Function to send Bluetooth command
  void sendBluetoothData(String command) {
    if (_isConnected && connection != null) {
      connection!.output.add(utf8.encode(command)); // Send data to the connected device
      connection!.output.allSent.then((_) {
        debugPrint('📡 Command $command sent to the car');  // Command sent successfully
      });
    } else {
      debugPrint('❌ Not connected to any Bluetooth device');
    }
  }

  // Function to update the Bluetooth connection status
  void updateConnectionStatus(BluetoothConnection? newConnection,bool isConnected) {
    setState(() {
      connection = newConnection;
      _isConnected = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildCard(
            context,
            imagePath: 'assets/images/remote.png',
            text: 'Bluetooth Car Remote',
            onTap: () => Navigator.pushNamed(context, '/remote'),
          ),
          _buildCard(
            context,
            imagePath: 'assets/images/automate.png',
            text: 'Bluetooth Automation',
            onTap: () => Navigator.pushNamed(context, '/automate'),
          ),
          _buildCard(
            context,
            imagePath: 'assets/images/mic.png',
            text: 'Bluetooth Voice Control',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoiceControlPage(
                  sendBluetoothData: sendBluetoothData,
                  updateConnection: updateConnectionStatus,  // Pass function to update connection status
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create a card widget
  Widget _buildCard(
    BuildContext context, {
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(137, 154, 174, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


}
