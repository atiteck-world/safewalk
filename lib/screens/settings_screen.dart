import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<AppSettings> settingsBox;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<AppSettings>('appSettings');
    _loadSettings();
  }

  void _loadSettings() {
    // Get existing settings or create default
    if (settingsBox.isEmpty) {
      final defaultSettings = AppSettings();
      settingsBox.add(defaultSettings);
    }
    final settings = settingsBox.getAt(0)!;
    _messageController.text = settings.customMessage;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: settingsBox.listenable(),
        builder: (context, Box<AppSettings> box, _) {
          if (box.isEmpty) return const SizedBox();

          final settings = box.getAt(0)!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Emergency Settings', isDarkMode),
                const SizedBox(height: 16),

                _buildSettingsCard([
                  _buildMessageSection(settings, isDarkMode),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Shake to Alert',
                    subtitle: 'Shake phone to send emergency alert',
                    icon: Icons.vibration,
                    value: settings.shakeEnabled,
                    isDarkMode: isDarkMode,
                    onChanged: (value) {
                      settings.shakeEnabled = value;
                      settings.save();
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Location Sharing',
                    subtitle: 'Include location in emergency messages',
                    icon: Icons.location_on,
                    value: settings.locationSharingEnabled,
                    isDarkMode: isDarkMode,
                    onChanged: (value) {
                      settings.locationSharingEnabled = value;
                      settings.save();
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 24),
                _buildSectionHeader('App Settings', isDarkMode),
                const SizedBox(height: 16),

                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive app notifications',
                    icon: Icons.notifications,
                    value: settings.notificationsEnabled,
                    isDarkMode: isDarkMode,
                    onChanged: (value) {
                      settings.notificationsEnabled = value;
                      settings.save();
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    icon: Icons.dark_mode,
                    value: settings.darkMode,
                    isDarkMode: isDarkMode,
                    onChanged: (value) {
                      settings.darkMode = value;
                      settings.save();
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 24),
                _buildSectionHeader('App Information', isDarkMode),
                const SizedBox(height: 16),

                _buildSettingsCard([
                  _buildInfoTile(
                    title: 'Version',
                    subtitle: '1.0.0',
                    icon: Icons.info_outline,
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    title: 'Emergency Contacts',
                    subtitle: 'Manage your emergency contacts',
                    icon: Icons.contact_emergency,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pushNamed(context, '/contacts');
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: Colors.grey.shade700, width: 0.5)
            : null,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMessageSection(AppSettings settings, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.green.shade900.withOpacity(0.3)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.message,
                  color: isDarkMode
                      ? Colors.green.shade300
                      : Colors.green.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Emergency Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 3,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter your emergency message...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF3C3C3C)
                  : Colors.grey.shade50,
            ),
            onChanged: (value) {
              settings.customMessage = value;
              settings.save();
            },
          ),
          const SizedBox(height: 8),
          Text(
            'This message will be sent with your location during emergencies.',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.indigo.shade900.withOpacity(0.3)
                  : Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDarkMode
                  ? Colors.indigo.shade300
                  : Colors.indigo.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo.shade600,
            inactiveThumbColor: isDarkMode
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            inactiveTrackColor: isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
