import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_rounded, size: 80, color: Color(0xFF10B981)),
            SizedBox(height: 24),
            Text(
              "Welcome Home",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "Your daily summary and feed goes here.",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
