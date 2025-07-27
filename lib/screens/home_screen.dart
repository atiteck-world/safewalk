import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/emergency_service.dart';
import '../models/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EmergencyService emergencyService = EmergencyService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SafeWalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
                : [Colors.indigo, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Welcome section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2C2C2C).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shield,
                        size: 50,
                        color: isDarkMode ? Colors.white : Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome to SafeWalk!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your safety companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Main custom action buttons
                _buildActionButton(
                  context,
                  onPressed: () => Navigator.pushNamed(context, '/trip'),
                  icon: Icons.directions_walk,
                  label: 'Start Trip',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                _buildActionButton(
                  context,
                  onPressed: () => Navigator.pushNamed(context, '/contacts'),
                  icon: Icons.contact_emergency,
                  label: 'Emergency Contacts',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                _buildActionButton(
                  context,
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 30),

                // Emergency button with actual functionality
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showEmergencyDialog(context, emergencyService),
                    icon: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(
    BuildContext context,
    EmergencyService emergencyService,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get current settings
    final settingsBox = Hive.box<AppSettings>('appSettings');
    AppSettings? settings;

    if (settingsBox.isNotEmpty) {
      settings = settingsBox.getAt(0);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emergency Alert',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will send ${settings?.locationSharingEnabled == true ? "your location and emergency message" : "your emergency message"} to ALL emergency contacts.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Settings info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.blue.shade900.withOpacity(0.3)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.blue.shade700
                        : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: isDarkMode
                              ? Colors.blue.shade300
                              : Colors.blue.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Current Settings:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Message: "${settings?.customMessage ?? "Default message"}"',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      '• Location: ${settings?.locationSharingEnabled == true ? "Enabled" : "Disabled"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.red.shade900.withOpacity(0.3)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.red.shade700
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use only in real emergencies',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              emergencyService.sendEmergencyAlert(context: context);
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text(
              'Send Alert',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
