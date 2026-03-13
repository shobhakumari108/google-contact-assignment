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
        title: Consumer<ContactProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                const Text('Contact Manager'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.contactController.isOnline 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: provider.contactController.isOnline 
                          ? Colors.green
                          : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.contactController.isOnline 
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        size: 16,
                        color: provider.contactController.isOnline 
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.contactController.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: provider.contactController.isOnline 
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.contactController.isSyncing)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          Consumer<ContactProvider>(
            builder: (context, provider, child) {
              if (provider.contactController.isOnline && 
                  provider.contactController.isSyncing == false) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    await provider.contactController.syncToCloud();
                    provider.showSuccessMessage('Sync completed');
                  },
                  tooltip: 'Sync to cloud',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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
              elevation: 4,
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
