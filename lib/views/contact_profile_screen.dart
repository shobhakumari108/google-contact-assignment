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
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Contact contact) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF6366F1),
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
                    color: Color(0xFF6366F1),
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
            // Get the updated contact from the controller to ensure we have the latest state
            final updatedContact = provider.contactController.contacts
                .firstWhere((c) => c.id == contact.id, orElse: () => contact);
            
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  updatedContact.isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(updatedContact.isFavorite),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onPressed: () async {
                try {
                  final newFavoriteStatus = !updatedContact.isFavorite;
                  
                  // Show immediate feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newFavoriteStatus
                            ? 'Adding to favorites...'
                            : 'Removing from favorites...',
                      ),
                      duration: const Duration(milliseconds: 500),
                      backgroundColor: Colors.grey[700],
                    ),
                  );
                  
                  await provider.contactController
                      .toggleFavorite(updatedContact.id!, newFavoriteStatus);
                  
                  // Show success message
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
          icon: const Icon(Icons.more_vert, color: Colors.white),
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
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        // Get the updated contact to ensure we have the latest state
        final updatedContact = provider.contactController.contacts
            .firstWhere((c) => c.id == contact.id, orElse: () => contact);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favorite status indicator
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      updatedContact.isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(updatedContact.isFavorite),
                      color: updatedContact.isFavorite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Favorite Status',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    updatedContact.isFavorite ? 'Added to favorites' : 'Not in favorites',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: updatedContact.isFavorite ? Colors.red : Colors.black87,
                    ),
                  ),
                  onTap: () async {
                    try {
                      final newFavoriteStatus = !updatedContact.isFavorite;
                      await provider.contactController
                          .toggleFavorite(updatedContact.id!, newFavoriteStatus);
                      provider.showSuccessMessage(
                        newFavoriteStatus
                            ? 'Added to favorites'
                            : 'Removed from favorites',
                      );
                    } catch (e) {
                      provider.handleError('Failed to update favorite status');
                    }
                  },
                ),
              ),
              if (updatedContact.company != null && updatedContact.company!.isNotEmpty)
                _buildInfoSection(
                  'Company',
                  updatedContact.company!,
                  Icons.business,
                ),
              if (updatedContact.phoneNumber.isNotEmpty)
                _buildInfoSection(
                  'Phone',
                  updatedContact.phoneNumber,
                  Icons.phone,
                  onTap: () => _makePhoneCall(updatedContact.phoneNumber),
                ),
              if (updatedContact.email != null && updatedContact.email!.isNotEmpty)
                _buildInfoSection(
                  'Email',
                  updatedContact.email!,
                  Icons.email,
                  onTap: () => _sendEmail(updatedContact.email!),
                ),
              if (updatedContact.address != null && updatedContact.address!.isNotEmpty)
                _buildInfoSection(
                  'Address',
                  updatedContact.address!,
                  Icons.location_on,
                ),
              if (updatedContact.notes != null && updatedContact.notes!.isNotEmpty)
                _buildNotesSection(updatedContact),
              const SizedBox(height: 24),
              _buildActionButtons(context, updatedContact),
              const SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        );
      },
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(icon, color: const Color(0xFF6366F1), size: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: onTap != null 
              ? const Icon(Icons.open_in_new, color: Color(0xFF6366F1), size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildNotesSection(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Color(0xFF6366F1), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Notes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contact.notes!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
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
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
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
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
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
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
