import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import '../models/settings.dart';
import '../services/location_services.dart';

class EmergencyService {
  final LocationServices _locationServices = LocationServices();

  Future<void> sendEmergencyAlert({
    required BuildContext context,
    String? customMessage,
  }) async {
    try {
      // Get settings from Hive
      final settingsBox = Hive.box<AppSettings>('appSettings');
      AppSettings? settings;

      if (settingsBox.isNotEmpty) {
        settings = settingsBox.getAt(0);
      }

      // Check if location sharing is enabled in settings
      if (settings != null && !settings.locationSharingEnabled) {
        // Send message without location
        await _sendMessageWithoutLocation(context, settings, customMessage);
        return;
      }

      // Get emergency contacts
      final contactsBox = Hive.box<Contact>('emergencyContacts');
      final contacts = contactsBox.values.toList();

      if (contacts.isEmpty) {
        _showErrorSnackBar(
          context,
          'No emergency contacts found. Please add contacts first.',
        );
        return;
      }

      // Get current location (if location sharing is enabled)
      Position? position;
      if (settings == null || settings.locationSharingEnabled) {
        position = await _locationServices.getCurrentLocation();
        if (position == null) {
          _showErrorSnackBar(context, 'Unable to get current location.');
          return;
        }
      }

      // Create message using settings
      final message = _createEmergencyMessage(
        position,
        customMessage,
        settings,
      );

      // Send to all emergency contacts
      await _sendToAllContacts(context, contacts, message);
    } catch (e) {
      print('Emergency alert error: $e');
      _showErrorSnackBar(context, 'Failed to send emergency alert: $e');
    }
  }

  Future<void> _sendMessageWithoutLocation(
    BuildContext context,
    AppSettings settings,
    String? customMessage,
  ) async {
    try {
      // Get emergency contacts
      final contactsBox = Hive.box<Contact>('emergencyContacts');
      final contacts = contactsBox.values.toList();

      if (contacts.isEmpty) {
        _showErrorSnackBar(
          context,
          'No emergency contacts found. Please add contacts first.',
        );
        return;
      }

      // Create message without location
      final message = _createEmergencyMessage(null, customMessage, settings);

      // Send to all emergency contacts
      await _sendToAllContacts(context, contacts, message);
    } catch (e) {
      print('Emergency alert error: $e');
      _showErrorSnackBar(context, 'Failed to send emergency alert: $e');
    }
  }

  String _createEmergencyMessage(
    Position? position,
    String? customMessage,
    AppSettings? settings,
  ) {
    // Use custom message from settings, or fallback to parameter, or use default
    String baseMessage;

    if (settings != null && settings.customMessage.isNotEmpty) {
      baseMessage = settings.customMessage;
    } else if (customMessage != null && customMessage.isNotEmpty) {
      baseMessage = customMessage;
    } else {
      baseMessage = 'EMERGENCY ALERT! I need help!';
    }

    // If location sharing is disabled or no position available
    if (position == null) {
      return '''$baseMessage

Location sharing is disabled or unavailable.

Sent from SafeWalk App
Time: ${DateTime.now().toString()}''';
    }

    // Include location if available
    final googleMapsUrl =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    return '''$baseMessage

My current location:
Latitude: ${position.latitude.toStringAsFixed(6)}
Longitude: ${position.longitude.toStringAsFixed(6)}

View on map: $googleMapsUrl

Sent from SafeWalk App
Time: ${DateTime.now().toString()}''';
  }

  Future<void> _sendToAllContacts(
    BuildContext context,
    List<Contact> contacts,
    String message,
  ) async {
    int successCount = 0;
    int failureCount = 0;

    for (Contact contact in contacts) {
      try {
        await _sendSMS(contact.cleanPhoneNumber, message);
        successCount++;
      } catch (e) {
        print('Failed to send SMS to ${contact.name}: $e');
        failureCount++;
      }
    }

    // Show result
    if (successCount > 0) {
      _showSuccessSnackBar(
        context,
        'Emergency alert sent to $successCount contact${successCount > 1 ? 's' : ''}!',
      );
    }

    if (failureCount > 0) {
      _showErrorSnackBar(
        context,
        'Failed to send to $failureCount contact${failureCount > 1 ? 's' : ''}. Please check phone numbers.',
      );
    }
  }

  Future<void> sendLocationToContact(
    BuildContext context,
    Contact contact,
  ) async {
    try {
      // Get settings to check if location sharing is enabled
      final settingsBox = Hive.box<AppSettings>('appSettings');
      AppSettings? settings;

      if (settingsBox.isNotEmpty) {
        settings = settingsBox.getAt(0);
      }

      // Check if location sharing is enabled
      if (settings != null && !settings.locationSharingEnabled) {
        _showErrorSnackBar(
          context,
          'Location sharing is disabled in settings.',
        );
        return;
      }

      Position? position = await _locationServices.getCurrentLocation();
      if (position == null) {
        _showErrorSnackBar(context, 'Unable to get current location.');
        return;
      }

      final message = _createLocationMessage(
        position,
        'Sharing my current location with you:',
      );
      await _sendSMS(contact.cleanPhoneNumber, message);

      _showSuccessSnackBar(context, 'Location sent to ${contact.name}!');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to send location to ${contact.name}');
    }
  }

  String _createLocationMessage(Position position, String? customMessage) {
    final googleMapsUrl =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    final baseMessage =
        customMessage ?? 'Sharing my current location with you:';

    return '''$baseMessage

My current location:
Latitude: ${position.latitude.toStringAsFixed(6)}
Longitude: ${position.longitude.toStringAsFixed(6)}

View on map: $googleMapsUrl

Sent from SafeWalk App
Time: ${DateTime.now().toString()}''';
  }

  Future<void> _sendSMS(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception('Could not launch SMS for $phoneNumber');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
