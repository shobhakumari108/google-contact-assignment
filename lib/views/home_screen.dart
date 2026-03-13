import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import 'contacts_screen.dart';
import 'favorites_screen.dart';
import 'add_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const ContactsScreen(),
    const FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactProvider>(context, listen: false).setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Manager'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          return IndexedStack(
            index: provider.currentIndex,
            children: _screens,
          );
        },
      ),
      floatingActionButton: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddContactScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          return NavigationBar(
            selectedIndex: provider.currentIndex,
            onDestinationSelected: (index) {
              provider.setIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.contacts),
                label: 'Contacts',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
            ],
          );
        },
      ),
    );
  }
}
