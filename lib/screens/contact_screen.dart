import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {

    if (await Permission.contacts.request().isGranted) {
      try {

        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts.toList();
        });
      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is required.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _contacts.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          return ListTile(
            leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.displayName ?? 'No Name'),
            subtitle: Text(
              contact.phones != null && contact.phones!.isNotEmpty
                  ? contact.phones!.first.value ?? ''
                  : 'No Phone Number',
            ),
          );
        },
      ),
    );
  }
}
