import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safewalk/models/contact.dart';
import 'package:safewalk/screens/emergency_contacts_screen.dart';
import 'package:safewalk/screens/home_screen.dart';
import 'package:safewalk/screens/trip_tracker_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register the Contact adapter
  await Hive.initFlutter();

  // Register the Contact adapter
  Hive.registerAdapter(ContactAdapter());

  // Open the box for storing contacts
  await Hive.openBox<Contact>('emergencyContacts');
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
        '/contacts': (context) => const EmergencyContactsScreen(),
      },
    );
  }
}
