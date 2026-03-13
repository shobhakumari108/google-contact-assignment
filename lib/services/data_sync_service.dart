import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/contact_model.dart';

class DataSyncService extends ChangeNotifier {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final DatabaseService _dbService = DatabaseService();


  Future<void> initialize() async {
    try {
      await _dbService.database;
      print('DataSyncService initialized with local database only');
    } catch (e) {
      print('DataSyncService initialization failed: $e');
    }
  }




  // Contact operations
  Future<List<Contact>> getContacts() async {
    // Always use local database
    return await _dbService.getContacts();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    return await _dbService.getFavoriteContacts();
  }

  Future<void> addContact(Contact contact) async {
    // Add to local database
    final contactWithId = contact.copyWith(
      id: contact.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await _dbService.addContact(contactWithId);
  }

  Future<void> updateContact(Contact contact) async {
    // Update local database
    await _dbService.updateContact(contact);
  }

  Future<void> deleteContact(String contactId) async {
    // Delete from local database
    await _dbService.deleteContact(contactId);
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
    // Return stream from local database (simplified)
    return Stream.fromFuture(getContacts());
  }

  Stream<List<Contact>> getFavoriteContactsStream() {
    return Stream.fromFuture(getFavoriteContacts());
  }


}
