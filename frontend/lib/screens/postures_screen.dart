import 'package:flutter/material.dart';

class PosturesScreen extends StatelessWidget {
  const PosturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.accessibility_new_rounded, size: 80, color: Color(0xFF6366F1)),
            SizedBox(height: 24),
            Text(
              "Postures",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Posture analysis AI and metrics will go here.", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
