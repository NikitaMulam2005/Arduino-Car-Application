import 'package:flutter/material.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

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
            route: '/remote',
          ),
          _buildCard(
            context,
            imagePath: 'assets/images/automate.png',
            text: 'Bluetooth Automation',
            route: '/automate',
          ),
          _buildCard(
            context,
            imagePath: 'assets/images/mic.png',
            text: 'Bluetooth Voice Control',
            route: '/voice',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String imagePath,
    required String text,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
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
