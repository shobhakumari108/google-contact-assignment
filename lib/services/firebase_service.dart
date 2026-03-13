import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  bool _isInitialized = false;
  List<Contact> _localContacts = [];

  Future<void> initialize() async {
    try {
      // Skip Firebase initialization on web to avoid configuration issues
      if (kIsWeb) {
        print('Running on web - using local storage mode');
        _isInitialized = false;
        return;
      }
      
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isInitialized = true;
        print('Firebase already initialized, using existing instance');
        return;
      }
      
      // Try to initialize Firebase only on non-web platforms
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
      print('Running in local mode - data will not persist');
      _isInitialized = false;
    }
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase is not initialized');
    }
    return _firestore!;
  }
  
  bool get isInitialized => _isInitialized;

  // Contact operations
  Future<List<Contact>> getContacts() async {
    if (!_isInitialized) return _localContacts;
    final snapshot = await _firestore!.collection('contacts').get();
    return snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    if (!_isInitialized) return _localContacts.where((c) => c.isFavorite).toList();
    final snapshot = await _firestore!
        .collection('contacts')
        .where('isFavorite', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
  }

  Future<void> addContact(Contact contact) async {
    if (!_isInitialized) {
      _localContacts.add(contact.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
      return;
    }
    await _firestore!.collection('contacts').add(contact.toFirestore());
  }

  Future<void> updateContact(Contact contact) async {
    if (!_isInitialized) {
      final index = _localContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _localContacts[index] = contact;
      }
      return;
    }
    if (contact.id != null) {
      await _firestore!.collection('contacts').doc(contact.id).update(contact.toFirestore());
    }
  }

  Future<void> deleteContact(String contactId) async {
    if (!_isInitialized) {
      _localContacts.removeWhere((c) => c.id == contactId);
      return;
    }
    await _firestore!.collection('contacts').doc(contactId).delete();
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    if (!_isInitialized) {
      final index = _localContacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _localContacts[index] = _localContacts[index].copyWith(isFavorite: isFavorite);
      }
      return;
    }
    await _firestore!.collection('contacts').doc(contactId).update({'isFavorite': isFavorite});
  }

  Stream<List<Contact>> getContactsStream() {
    if (!_isInitialized) {
      // Return a stream that emits local contacts
      return Stream.value(_localContacts);
    }
    return _firestore!.collection('contacts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList());
  }

  Stream<List<Contact>> getFavoriteContactsStream() {
    if (!_isInitialized) {
      return Stream.value(_localContacts.where((c) => c.isFavorite).toList());
    }
    return _firestore!
        .collection('contacts')
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList());
  }
}
