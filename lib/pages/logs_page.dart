// ignore: file_names
import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example log data
    final logs = [
      'User logged in',
      'User viewed profile',
      'User played video',
      'User logged out',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(logs[index]),
          );
        },
      ),
    );
  }
}
