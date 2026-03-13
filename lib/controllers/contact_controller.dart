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

  ContactController() {
    _initializeData();
    _dataSyncService.addListener(_onDataSyncServiceChanged);
  }

  void _onDataSyncServiceChanged() {
    notifyListeners();
  }

  Future<void> _initializeData() async {
    try {
      _setLoading(true);
      notifyListeners(); // Notify immediately to show loading state
      
      await _dataSyncService.initialize();
      await loadContacts();
    } catch (e) {
      _setError('Failed to initialize data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadContacts() async {
    final contacts = await _dataSyncService.getContacts();
    final favorites = await _dataSyncService.getFavoriteContacts();
    _contacts = contacts;
    _favoriteContacts = favorites;
    
    // Mark initial loading as complete after first successful load
    if (_isLoading) {
      _setLoading(false);
    }
    
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    try {
      _setLoading(true);
      await _dataSyncService.addContact(contact);
      await loadContacts();
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
      await loadContacts();
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
      await loadContacts();
      _clearError();
    } catch (e) {
      _setError('Failed to delete contact: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    try {
      // Update local state immediately for instant UI feedback
      final contactIndex = _contacts.indexWhere((c) => c.id == contactId);
      if (contactIndex != -1) {
        _contacts[contactIndex] = _contacts[contactIndex].copyWith(isFavorite: isFavorite);
        
        // Update favorites list
        if (isFavorite) {
          if (!_favoriteContacts.any((c) => c.id == contactId)) {
            _favoriteContacts.add(_contacts[contactIndex]);
          }
        } else {
          _favoriteContacts.removeWhere((c) => c.id == contactId);
        }
        
        notifyListeners();
      }
      
      // Then sync with database (don't reload contacts as we already updated local state)
      await _dataSyncService.toggleFavorite(contactId, isFavorite);
      _clearError();
    } catch (e) {
      _setError('Failed to update favorite status: ${e.toString()}');
      // Reload contacts to restore correct state only on error
      await loadContacts();
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
    _dataSyncService.removeListener(_onDataSyncServiceChanged);
    super.dispose();
  }
}
