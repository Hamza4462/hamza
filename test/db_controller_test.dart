import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:doctor_app2/controllers/db_controller.dart';
import 'package:doctor_app2/models/patient.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DBController', () {
    test('create/read/update/delete patient', () async {
      final dbc = DBController.instance;

      // create
      final p = Patient(name: 'Test', age: 30, gender: 'M', phone: '123');
      final created = await dbc.createPatient(p);
      expect(created.id, isNotNull);

      // read
      final list = await dbc.readAllPatients();
      expect(list.any((e) => e.name == 'Test'), isTrue);

      // update
      created.name = 'Updated';
      final updatedCount = await dbc.updatePatient(created);
      expect(updatedCount, 1);

      // delete
      final deleted = await dbc.deletePatient(created.id!);
      expect(deleted, 1);
    });
  });
}
