import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A test version of DatabaseService that uses an in-memory database
class TestDatabaseService {
  static final TestDatabaseService instance = TestDatabaseService._init();
  static Database? _database;
  
  TestDatabaseService._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize FFI for testing
    sqfliteFfiInit();
    
    // Create the database in memory
    var databaseFactory = databaseFactoryFfi;
    _database = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createTables,
      ),
    );
    
    return _database!;
  }
  
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        notes TEXT,
        imagePath TEXT,
        attachments TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        phone TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }
  
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
