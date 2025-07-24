import 'package:flutter/material.dart';

class TripTrackerScreen extends StatelessWidget {
  const TripTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Tracker'),
      ),
      body: Center(
        child: const Text(
          'Track your trip details here.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
