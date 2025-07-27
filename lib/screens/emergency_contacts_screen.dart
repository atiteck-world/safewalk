import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import '../services/emergency_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  late Box<Contact> contactsBox;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final EmergencyService _emergencyService = EmergencyService();

  @override
  void initState() {
    super.initState();
    contactsBox = Hive.box<Contact>('emergencyContacts');
  }

  List<Contact> get _contacts => contactsBox.values.toList();

  Future<void> _addContact() async {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Please enter both name and phone number.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final Contact newContact = Contact(name: name, phone: phone);
      await contactsBox.add(newContact);
      setState(() {
        _nameController.clear();
        _phoneController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Contact added successfully!')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Failed to add contact.')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAddContactSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Colors.red.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextField(
              controller: _phoneController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: Colors.red.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey.shade50,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Add Contact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeContact(int index) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contacts = contactsBox.values.toList();
    final Contact contact = contacts[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Contact',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to remove ${contact.name}?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await contact.delete();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Contact removed successfully!'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Failed to remove contact.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text('Remove', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  void _showEditContactSheet(Contact contact) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Pre-fill the text controllers with existing contact data
    _nameController.text = contact.name;
    _phoneController.text = contact.phone;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Edit Emergency Contact',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Colors.red.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextField(
              controller: _phoneController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: Colors.red.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey.shade50,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _updateContact(contact),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Update Contact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateContact(Contact contact) async {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Please enter both name and phone number.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Update the existing contact
      contact.name = name;
      contact.phone = phone;
      await contact.save();

      setState(() {
        _nameController.clear();
        _phoneController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Contact updated successfully!')),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Failed to update contact.')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showContactOptions(Contact contact, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              contact.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              contact.phone,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Send Location Option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Icon(Icons.location_on, color: Colors.orange.shade600),
              ),
              title: Text(
                'Send Location',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Share your current location',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _emergencyService.sendLocationToContact(context, contact);
              },
            ),

            // Edit Option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.edit, color: Colors.blue.shade600),
              ),
              title: Text(
                'Edit Contact',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Modify contact information',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditContactSheet(contact);
              },
            ),

            // Delete Option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Icon(Icons.delete, color: Colors.red.shade600),
              ),
              title: Text(
                'Delete Contact',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Remove from emergency contacts',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeContact(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
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
        valueListenable: contactsBox.listenable(),
        builder: (context, Box<Contact> box, _) {
          final contacts = box.values.toList();

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 80,
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No emergency contacts yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add trusted contacts for emergencies',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    radius: 25,
                    child: Icon(
                      Icons.person,
                      color: Colors.red.shade600,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      contact.phone,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      size: 24,
                    ),
                    onPressed: () => _showContactOptions(contact, index),
                  ),
                  onTap: () => _showContactOptions(contact, index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactSheet,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Add Contact',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
