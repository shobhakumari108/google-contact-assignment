import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE contacts(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phoneNumber TEXT NOT NULL,
            email TEXT,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Contact operations
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        email: maps[i]['email'],
        isFavorite: maps[i]['isFavorite'] == 1,
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
      );
    });
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        email: maps[i]['email'],
        isFavorite: maps[i]['isFavorite'] == 1,
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
      );
    });
  }

  Future<List<Contact>> getUnsyncedContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'updatedAt ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        email: maps[i]['email'],
        isFavorite: maps[i]['isFavorite'] == 1,
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
      );
    });
  }

  Future<Contact?> getContactById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final map = maps.first;
      return Contact(
        id: map['id'],
        name: map['name'],
        phoneNumber: map['phoneNumber'],
        email: map['email'],
        isFavorite: map['isFavorite'] == 1,
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
      );
    }
    return null;
  }

  Future<void> addContact(Contact contact) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'contacts',
      {
        'id': contact.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'email': contact.email,
        'isFavorite': contact.isFavorite ? 1 : 0,
        'createdAt': now,
        'updatedAt': now,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      {
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'email': contact.email,
        'isFavorite': contact.isFavorite ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String contactId) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  Future<void> markAsSynced(String contactId) async {
    final db = await database;
    await db.update(
      'contacts',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  Future<void> syncFromFirebase(List<Contact> contacts) async {
    final db = await database;
    final batch = db.batch();

    for (final contact in contacts) {
      batch.insert(
        'contacts',
        {
          'id': contact.id,
          'name': contact.name,
          'phoneNumber': contact.phoneNumber,
          'email': contact.email,
          'isFavorite': contact.isFavorite ? 1 : 0,
          'createdAt': contact.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updatedAt': contact.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearAllContacts() async {
    final db = await database;
    await db.delete('contacts');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
