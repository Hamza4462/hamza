import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:doctor_app2/services/database_service.dart';
import 'package:path/path.dart' as path;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Schema Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService.instance;
      // Use a test-specific database file
      dbService.overrideDatabasePath(path.join(path.current, 'test_db.sqlite'));
      await dbService.init();
    });

    tearDown(() async {
      await dbService.close();
      // Clean up test database
      await deleteDatabase(path.join(path.current, 'test_db.sqlite'));
    });

    test('verify tables exist with correct schemas', () async {
      final db = await dbService.database;
      
      // Check tables exist
      final tables = await db.query('sqlite_master', 
        where: "type = 'table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, containsAll(['patients', 'doctors', 'appointments', 'payments']));

      // Verify patients table schema
      final patientsSchema = await db.rawQuery('PRAGMA table_info(patients)');
      expect(patientsSchema.any((col) => col['name'] == 'phone' && col['notnull'] == 1), isTrue);
      expect(patientsSchema.any((col) => col['name'] == 'image_path'), isTrue);

      // Verify appointments table schema
      final appointmentsSchema = await db.rawQuery('PRAGMA table_info(appointments)');
      expect(appointmentsSchema.any((col) => col['name'] == 'patient_id' && col['notnull'] == 1), isTrue);
      expect(appointmentsSchema.any((col) => col['name'] == 'doctor_id' && col['notnull'] == 1), isTrue);
      expect(appointmentsSchema.any((col) => col['name'] == 'date_time' && col['notnull'] == 1), isTrue);

      // Verify payments table schema
      final paymentsSchema = await db.rawQuery('PRAGMA table_info(payments)');
      expect(paymentsSchema.any((col) => col['name'] == 'appointment_id' && col['notnull'] == 1), isTrue);
      expect(paymentsSchema.any((col) => col['name'] == 'amount' && col['notnull'] == 1), isTrue);
      expect(paymentsSchema.any((col) => col['name'] == 'payment_method' && col['notnull'] == 1), isTrue);

      // Verify foreign keys
      final appointmentsForeignKeys = await db.rawQuery('PRAGMA foreign_key_list(appointments)');
      expect(appointmentsForeignKeys.length, 2); // Should have 2 foreign keys
      expect(appointmentsForeignKeys.any((fk) => fk['table'] == 'patients'), isTrue);
      expect(appointmentsForeignKeys.any((fk) => fk['table'] == 'doctors'), isTrue);

      final paymentsForeignKeys = await db.rawQuery('PRAGMA foreign_key_list(payments)');
      expect(paymentsForeignKeys.length, 1); // Should have 1 foreign key
      expect(paymentsForeignKeys.first['table'], equals('appointments'));
    });

    test('verify database upgrade from v1 to v2', () async {
      // First create a v1 database
      final v1Path = path.join(path.current, 'test_db_v1.sqlite');
      final v1Db = await openDatabase(
        v1Path,
        version: 1,
        onCreate: (db, version) async {
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
      );
      await v1Db.close();

      // Now open it with v2 schema
      final v2Db = await openDatabase(
        v1Path,
        version: 2,
        onUpgrade: dbService.onUpgrade,
      );

      // Verify the upgrades
      final tables = await v2Db.query('sqlite_master', 
        where: "type = 'table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, containsAll(['appointments', 'payments']));

      // Check if imagePath was renamed to image_path
      final patientsSchema = await v2Db.rawQuery('PRAGMA table_info(patients)');
      expect(patientsSchema.any((col) => col['name'] == 'image_path'), isTrue);
      expect(patientsSchema.any((col) => col['name'] == 'imagePath'), isFalse);

      await v2Db.close();
      await deleteDatabase(v1Path);
    });
  });
}