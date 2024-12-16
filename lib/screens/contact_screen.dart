import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    bool permissionGranted = await PermissionUtils.requestContactPermission(context).timeout(Duration(seconds: 10),
        onTimeout: () {
          setState(() {
            _isError = true;
          });
          return false;
        });

    if (permissionGranted) {
      try {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts.toList();
        });
      } catch (e) {
        _contacts = [];
         _isError = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    } else {

      _contacts = [];
       _isError = true;
      setState(() {

      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is required.')),
      );
    }
  }


  Future<void> _makeCall({required String contact}) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: contact);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body:  _isError
          ? const Center(
        child: Text(
          'Failed to fetch contacts.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : _contacts.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          final contactPhones = contact.phones ?? [];
          return ExpansionTile(
            leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.displayName ?? 'No Name'),
            subtitle: Text(
              contactPhones.isNotEmpty ? contactPhones.first.value ?? '' : 'No Phone Number',
            ),
            children: contactPhones.map((phone) {
              return ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(phone.value ?? ''),
                onTap: () {
                  if (phone.value != null) {
                    _makeCall(contact: phone.value.toString()); // Call the number
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
