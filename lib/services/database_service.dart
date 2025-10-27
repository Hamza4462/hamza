import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static String? _overriddenDbPath;

  DatabaseService._init();

  // Method to override database path for testing
  void overrideDatabasePath(String path) {
    if (_database != null) {
      throw StateError('Cannot override database path after database is initialized');
    }
    _overriddenDbPath = path;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await _initMobileDatabase();
    } else {
      return await _initFFIDatabase();
    }
  }

  Future<Database> _initFFIDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();
    
    // Create the database using FFI
    final databaseFactory = databaseFactoryFfi;
    final String databasePath;
    
    if (_overriddenDbPath != null) {
      databasePath = _overriddenDbPath!;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      databasePath = path.join(directory.path, 'doctor_app.db');
    }
    
    return await databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: _createTables,
        onUpgrade: onUpgrade,
      ),
    );
  }

  Future<Database> _initMobileDatabase() async {
    final String databasePath;
    
    if (_overriddenDbPath != null) {
      databasePath = _overriddenDbPath!;
    } else {
      final dbPath = await getDatabasesPath();
      databasePath = path.join(dbPath, 'doctor_app.db');
    }
    
    return await openDatabase(
      databasePath,
      version: 3,
      onCreate: _createTables,
      onUpgrade: onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        notes TEXT,
        image_path TEXT,
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

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        date_time TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        transaction_id TEXT,
        notes TEXT,
        FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE treatments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL DEFAULT 0.0
      )
    ''');
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
      // Add unique constraint to patients phone
      try {
        await db.execute('ALTER TABLE patients ADD CONSTRAINT patient_unique_phone UNIQUE (phone)');
      } catch (e) {
        // Ignore if constraint already exists
      }

      // Rename imagePath column to image_path if it exists
      try {
        await db.execute('ALTER TABLE patients RENAME COLUMN imagePath TO image_path');
      } catch (e) {
        // Ignore if column doesn't exist or is already renamed
      }

      // Create appointments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS appointments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL,
          doctor_id INTEGER NOT NULL,
          date_time TEXT NOT NULL,
          status TEXT NOT NULL,
          notes TEXT,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
          FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
        )
      ''');

      // Create payments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          appointment_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          payment_method TEXT NOT NULL,
          status TEXT NOT NULL,
          transaction_id TEXT,
          notes TEXT,
          FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      // Create treatments table for v3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS treatments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL DEFAULT 0.0
        )
      ''');
    }
  }
}