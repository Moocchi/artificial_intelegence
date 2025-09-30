import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Ini Home Page ygy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/pictures/belle.gif',
            width: 200, // Optional: set width/height as needed
            height: 200,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
