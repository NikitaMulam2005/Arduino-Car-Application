import 'package:flutter/material.dart';
import 'package:arduino_app/home.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:arduino_app/landing.dart';
import 'package:arduino_app/remote.dart';
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
        textTheme: GoogleFonts.lobsterTextTheme(), // Optional global use of Lobster font
      ),
      home: const HomeScreen(), // 🚀 First screen to load
      routes: {
        // make sure you have LandingScreen defined
         '/landing': (context) => const LandingScreen(),
        '/remote': (context) => const BluetoothCarController(),
      },
    );
  }
}
