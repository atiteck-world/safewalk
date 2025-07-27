import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safewalk/models/contact.dart';
import 'package:safewalk/models/settings.dart';
import 'package:safewalk/screens/emergency_contacts_screen.dart';
import 'package:safewalk/screens/home_screen.dart';
import 'package:safewalk/screens/settings_screen.dart';
import 'package:safewalk/screens/trip_tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register the Contact adapter
  await Hive.initFlutter();
  //print('Hive initialized');

  // Register adapters
  Hive.registerAdapter(ContactAdapter());
  //print('Contact adapter registered');
  Hive.registerAdapter(AppSettingsAdapter());
  //print('AppSettings adapter registered');

  // Open the box for storing contacts
  await Hive.openBox<Contact>('emergencyContacts');
  //print('Emergency contacts box opened');
  await Hive.openBox<AppSettings>('appSettings');
  //print('AppSettings box opened');

  runApp(SafeWalkApp());
}

class SafeWalkApp extends StatefulWidget {
  const SafeWalkApp({super.key});

  @override
  State<SafeWalkApp> createState() => _SafeWalkAppState();
}

class _SafeWalkAppState extends State<SafeWalkApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<AppSettings>('appSettings').listenable(),
      builder: (context, Box<AppSettings> box, _) {
        // Get the app settings from the box
        bool isDarkMode = false;
        if (box.isNotEmpty) {
          final settings = box.getAt(0)!;
          isDarkMode = settings.darkMode;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeWalk',

          // Light theme
          theme: ThemeData(
            primarySwatch: Colors.red,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey.shade50,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          // Dark theme
          darkTheme: ThemeData(
            primarySwatch: Colors.red,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E1E1E),
              elevation: 2,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Use dark mode if enabled in settings

          // Define the initial route and routes
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/trip': (context) => const TripTrackerScreen(),
            '/contacts': (context) => const EmergencyContactsScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
