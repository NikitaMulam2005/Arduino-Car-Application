import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadPage extends StatelessWidget {
  const ReadPage({super.key});

  Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Project Overview'),
            _buildText(
              'The system allows you to manage your devices remotely using your phone or through voice commands, '
              'and automate common tasks to make your life easier.',
            ),
            _buildSectionTitle('Features'),
            _buildText('- Bluetooth Control: The system communicates with the Arduino via Bluetooth.'),
            _buildText('- Voice Control: Voice commands are processed to control devices.'),
            _buildText('- Automation: Automatically control devices based on specific conditions.'),
            _buildSectionTitle('How It Works'),
            _buildText(
              'The app connects to your Arduino device via Bluetooth. Once connected, you can control various devices. '
              'You can also use voice commands to control these devices or set up automation tasks for convenience.',
            ),
            _buildSectionTitle('Visit Our Project'),
            GestureDetector(
              onTap: () => _launchURL('https://github.com/NikitaMulam2005/Arduino-Car-Application'),
              child: const Text(
                'Visit GitHub',
                style: TextStyle(
                  color: Color.fromRGBO(123, 163, 216, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.lobster(
          fontSize: 30,
          color: const Color.fromRGBO(50, 85, 131, 1),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.lobster(
          fontSize: 24,
          color: const Color.fromRGBO(50, 85, 131, 1),
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
          color: Color.fromRGBO(60, 60, 60, 1),
        ),
      ),
    );
  }
}
