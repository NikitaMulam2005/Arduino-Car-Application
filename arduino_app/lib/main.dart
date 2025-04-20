import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arduino_app/home.dart';
import 'package:arduino_app/landing.dart';
import 'package:arduino_app/remote.dart';
import 'package:arduino_app/voice.dart';
import 'package:arduino_app/gps_service.dart';
import 'package:arduino_app/tracking_page.dart';
import 'package:arduino_app/login.dart';
import 'package:arduino_app/signup.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Automation Control App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.lobsterTextTheme(),
      ),
      home: const HomeScreen(),
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/remote': (context) => const HC05CarController(),
        '/tracker': (context) => const GPSTrackingPage(),
        '/automate': (context) => const GPSServicePage(),
         '/signup': (context) => const SignUpPage(),
         '/login': (context) => const LoginPage(),
        '/voice': (context) => VoiceControlPage(
          sendBluetoothData: (String command) {
            debugPrint('🔊 Sending command to Arduino: $command');
            // Add Bluetooth send logic here if needed
          },
          updateConnection: (BluetoothConnection? conn, bool isConnected) {
            debugPrint('Bluetooth Status: ${isConnected ? "Connected" : "Disconnected"}');
            // Handle Bluetooth connection status change
          },
        ),
      },
    );
  }
}
