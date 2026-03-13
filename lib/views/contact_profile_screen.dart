import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/contact_provider.dart';
import '../models/contact_model.dart';
import 'add_contact_screen.dart';

class ContactProfileScreen extends StatelessWidget {
  final String contactId;

  const ContactProfileScreen({
    super.key,
    required this.contactId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        final contact = provider.contactController.getContactById(contactId);
        
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Contact Not Found')),
            body: const Center(
              child: Text('Contact not found'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, contact),
              SliverToBoxAdapter(
                child: _buildProfileBody(context, contact),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContactScreen(contact: contact),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Contact contact) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  contact.name.isNotEmpty
                      ? contact.name[0].toUpperCase()
                      : '👤',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                contact.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<ContactProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () async {
                try {
                  final newFavoriteStatus = !contact.isFavorite;
                  await provider.contactController
                      .toggleFavorite(contact.id!, newFavoriteStatus);
                  provider.showSuccessMessage(
                    newFavoriteStatus
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  );
                } catch (e) {
                  provider.handleError('Failed to update favorite status');
                }
              },
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'call':
                _makePhoneCall(contact.phoneNumber);
                break;
              case 'delete':
                _showDeleteConfirmation(context, contact);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'call',
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Call'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileBody(BuildContext context, Contact contact) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.company != null && contact.company!.isNotEmpty)
            _buildInfoSection(
              'Company',
              contact.company!,
              Icons.business,
            ),
          if (contact.phoneNumber.isNotEmpty)
            _buildInfoSection(
              'Phone',
              contact.phoneNumber,
              Icons.phone,
              onTap: () => _makePhoneCall(contact.phoneNumber),
            ),
          if (contact.email != null && contact.email!.isNotEmpty)
            _buildInfoSection(
              'Email',
              contact.email!,
              Icons.email,
              onTap: () => _sendEmail(contact.email!),
            ),
          if (contact.address != null && contact.address!.isNotEmpty)
            _buildInfoSection(
              'Address',
              contact.address!,
              Icons.location_on,
            ),
          if (contact.notes != null && contact.notes!.isNotEmpty)
            _buildNotesSection(contact),
          const SizedBox(height: 32),
          _buildActionButtons(context, contact),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: onTap != null ? const Icon(Icons.open_in_new) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotesSection(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Notes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contact.notes!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Contact contact) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(contact.phoneNumber),
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (contact.email != null && contact.email!.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _sendEmail(contact.email!),
              icon: const Icon(Icons.email),
              label: const Text('Send Email'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      final provider = ContactProvider.navigatorKey.currentContext != null
          ? Provider.of<ContactProvider>(ContactProvider.navigatorKey.currentContext!, listen: false)
          : null;
      provider?.handleError('Could not launch phone app');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      final provider = ContactProvider.navigatorKey.currentContext != null
          ? Provider.of<ContactProvider>(ContactProvider.navigatorKey.currentContext!, listen: false)
          : null;
      provider?.handleError('Could not launch email app');
    }
  }

  void _showDeleteConfirmation(BuildContext context, Contact contact) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              try {
                await provider.contactController.deleteContact(contact.id!);
                provider.showSuccessMessage('Contact deleted successfully');
              } catch (e) {
                provider.handleError('Failed to delete contact');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
