import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushNamed(context, '/login');
      };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Text
            Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 20, right: 20),
              child: Text(
                'Make Your Life Simpler With Our Automation Control',
                textAlign: TextAlign.center,
                style: GoogleFonts.lobster(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(9, 12, 12, 1),
                ),
              ),
            ),

            // Image Section
            Expanded(
              flex: 4,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: 300,
              ),
            ),

            // Get Started Button + Sign In Text
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/landing');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(50, 85, 131, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Already have an account ? '),
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: Color.fromRGBO(123, 163, 216, 1),
                          ),
                          recognizer: tapRecognizer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
