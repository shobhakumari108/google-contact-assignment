import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../services/data_sync_service.dart';

class ContactController extends ChangeNotifier {
  final DataSyncService _dataSyncService = DataSyncService();
  List<Contact> _contacts = [];
  List<Contact> _favoriteContacts = [];
  bool _isLoading = false;
  String? _error;

  List<Contact> get contacts => _contacts;
  List<Contact> get favoriteContacts => _favoriteContacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _dataSyncService.isOnline;
  bool get isSyncing => _dataSyncService.isSyncing;

  ContactController() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _setLoading(true);
      await _dataSyncService.initialize();
      await _loadContacts();
    } catch (e) {
      _setError('Failed to initialize data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadContacts() async {
    final contacts = await _dataSyncService.getContacts();
    final favorites = await _dataSyncService.getFavoriteContacts();
    _contacts = contacts;
    _favoriteContacts = favorites;
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    try {
      _setLoading(true);
      await _dataSyncService.addContact(contact);
      await _loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to add contact: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      _setLoading(true);
      await _dataSyncService.updateContact(contact);
      await _loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to update contact: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      _setLoading(true);
      await _dataSyncService.deleteContact(contactId);
      await _loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to delete contact: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    try {
      await _dataSyncService.toggleFavorite(contactId, isFavorite);
      await _loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to update favorite status: ${e.toString()}');
    }
  }

  Future<void> refreshContacts() async {
    try {
      _setLoading(true);
      await _dataSyncService.refreshContacts();
      await _loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to refresh contacts: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncToCloud() async {
    try {
      await _dataSyncService.syncToFirebase();
      _clearError();
    } catch (e) {
      _setError('Failed to sync to cloud: ${e.toString()}');
    }
  }

  Contact? getContactById(String contactId) {
    try {
      return _contacts.firstWhere((contact) => contact.id == contactId);
    } catch (e) {
      return null;
    }
  }

  List<Contact> searchContacts(String query) {
    if (query.isEmpty) return _contacts;
    
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query.toLowerCase()) ||
          contact.phoneNumber.contains(query) ||
          (contact.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (contact.company?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<Contact> searchFavoriteContacts(String query) {
    if (query.isEmpty) return _favoriteContacts;
    
    return _favoriteContacts.where((contact) {
      return contact.name.toLowerCase().contains(query.toLowerCase()) ||
          contact.phoneNumber.contains(query) ||
          (contact.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (contact.company?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
