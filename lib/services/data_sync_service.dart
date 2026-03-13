import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'firebase_service.dart';
import '../models/contact_model.dart';

class DataSyncService extends ChangeNotifier {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final DatabaseService _dbService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isOnline = false;
  bool _isSyncing = false;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  void _setSyncingStatus(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _dbService.database;
    await _firebaseService.initialize();
    _isOnline = _firebaseService.isInitialized;
    
    if (_isOnline) {
      await _performInitialSync();
    }
  }

  Future<void> _performInitialSync() async {
    try {
      _setSyncingStatus(true);
      
      // Get all contacts from Firebase
      final firebaseContacts = await _firebaseService.getContacts();
      
      // Sync to local database
      await _dbService.syncFromFirebase(firebaseContacts);
      
      print('Initial sync completed: ${firebaseContacts.length} contacts synced');
    } catch (e) {
      print('Initial sync failed: $e');
    } finally {
      _setSyncingStatus(false);
    }
  }

  Future<void> syncToFirebase() async {
    if (!_isOnline || _isSyncing) return;
    
    try {
      _setSyncingStatus(true);
      
      // Get unsynced contacts
      final unsyncedContacts = await _dbService.getUnsyncedContacts();
      
      for (final contact in unsyncedContacts) {
        try {
          if (contact.id != null) {
            // Check if contact exists in Firebase
            final existingContact = await _getFirebaseContact(contact.id!);
            
            if (existingContact != null) {
              // Update existing contact
              await _firebaseService.updateContact(contact);
            } else {
              // Add new contact
              await _firebaseService.addContact(contact);
            }
          }
          
          // Mark as synced
          await _dbService.markAsSynced(contact.id!);
        } catch (e) {
          print('Failed to sync contact ${contact.id}: $e');
        }
      }
      
      print('Sync to Firebase completed');
    } catch (e) {
      print('Sync to Firebase failed: $e');
    } finally {
      _setSyncingStatus(false);
    }
  }

  Future<Contact?> _getFirebaseContact(String id) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('contacts')
          .doc(id)
          .get();
      
      if (snapshot.exists) {
        return Contact.fromFirestore(snapshot);
      }
      return null;
    } catch (e) {
      print('Error getting Firebase contact: $e');
      return null;
    }
  }

  // Contact operations
  Future<List<Contact>> getContacts() async {
    if (_isOnline) {
      try {
        // Try to get from Firebase first
        final firebaseContacts = await _firebaseService.getContacts();
        await _dbService.syncFromFirebase(firebaseContacts);
        return firebaseContacts;
      } catch (e) {
        print('Failed to get from Firebase, using local: $e');
      }
    }
    
    // Fallback to local database
    return await _dbService.getContacts();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    if (_isOnline) {
      try {
        final firebaseContacts = await _firebaseService.getFavoriteContacts();
        return firebaseContacts;
      } catch (e) {
        print('Failed to get favorites from Firebase, using local: $e');
      }
    }
    
    return await _dbService.getFavoriteContacts();
  }

  Future<void> addContact(Contact contact) async {
    // Add to local database first
    final contactWithId = contact.copyWith(
      id: contact.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await _dbService.addContact(contactWithId);
    
    // Sync to Firebase if online
    if (_isOnline) {
      try {
        await _firebaseService.addContact(contactWithId);
        await _dbService.markAsSynced(contactWithId.id!);
      } catch (e) {
        print('Failed to sync new contact to Firebase: $e');
        // Will be synced later
      }
    }
  }

  Future<void> updateContact(Contact contact) async {
    // Update local database first
    await _dbService.updateContact(contact);
    
    // Sync to Firebase if online
    if (_isOnline) {
      try {
        await _firebaseService.updateContact(contact);
        await _dbService.markAsSynced(contact.id!);
      } catch (e) {
        print('Failed to sync updated contact to Firebase: $e');
        // Will be synced later
      }
    }
  }

  Future<void> deleteContact(String contactId) async {
    // Delete from local database first
    await _dbService.deleteContact(contactId);
    
    // Delete from Firebase if online
    if (_isOnline) {
      try {
        await _firebaseService.deleteContact(contactId);
      } catch (e) {
        print('Failed to delete contact from Firebase: $e');
      }
    }
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    // Get current contact
    final contact = await _dbService.getContactById(contactId);
    if (contact != null) {
      final updatedContact = contact.copyWith(isFavorite: isFavorite);
      await updateContact(updatedContact);
    }
  }

  Stream<List<Contact>> getContactsStream() {
    if (_isOnline) {
      try {
        return _firebaseService.getContactsStream().map((contacts) async {
          // Update local cache
          await _dbService.syncFromFirebase(contacts);
          return contacts;
        }).asyncMap((future) => future);
      } catch (e) {
        print('Firebase stream failed, using local: $e');
      }
    }
    
    // Return stream from local database (simplified)
    return Stream.fromFuture(getContacts());
  }

  Stream<List<Contact>> getFavoriteContactsStream() {
    if (_isOnline) {
      try {
        return _firebaseService.getFavoriteContactsStream();
      } catch (e) {
        print('Firebase favorites stream failed, using local: $e');
      }
    }
    
    return Stream.fromFuture(getFavoriteContacts());
  }

  Future<void> refreshContacts() async {
    if (_isOnline) {
      await _performInitialSync();
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      notifyListeners();
      
      if (isOnline) {
        // When coming back online, sync any pending changes
        await syncToFirebase();
        await _performInitialSync();
      }
      
      print('Connection status changed: ${isOnline ? "Online" : "Offline"}');
    }
  }
}
