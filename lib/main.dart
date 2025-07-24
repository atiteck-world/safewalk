import 'package:flutter/material.dart';
import 'package:safewalk/screens/home_screen.dart';
import 'package:safewalk/screens/trip_tracker_screen.dart';

void main() {
  runApp(SafeWalkApp());
}

class SafeWalkApp extends StatelessWidget {
  const SafeWalkApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeWalk',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/trip': (context) => const TripTrackerScreen(),
      },
    );
  }
}
