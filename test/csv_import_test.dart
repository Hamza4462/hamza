import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:doctor_app2/controllers/db_controller.dart';
import 'package:csv/csv.dart';
import 'package:doctor_app2/utils/csv_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('CSV import inserts and updates by phone', () async {
    // remove any existing database so migrations/schema changes take effect
    final dbPath = await getDatabasesPath();
    final dbFile = File('$dbPath${Platform.pathSeparator}patients.db');
    if (await dbFile.exists()) await dbFile.delete();

    final db = DBController.instance;

    // prepare CSV content
    final rows = [
      ['id', 'name', 'age', 'gender', 'phone', 'notes', 'imagePath', 'attachments'],
      ['','Alice', '30', 'F', '555', 'note A', '', ''],
      ['','Bob', '40', 'M', '666', 'note B', '', ''],
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final tmp = Directory.systemTemp;
    final f = File('${tmp.path}/test_import.csv');
    await f.writeAsString(csv);

    await CsvUtil.importCsvToDb(f, db);
    final list = await db.readAllPatients();
    expect(list.length, greaterThanOrEqualTo(2));

    // import again with change to Alice name -> should update existing by phone
    final rows2 = [
      ['id', 'name', 'age', 'gender', 'phone', 'notes', 'imagePath', 'attachments'],
      ['','Alice Updated', '31', 'F', '555', 'note A2', '', ''],
    ];
    final csv2 = const ListToCsvConverter().convert(rows2);
    final f2 = File('${tmp.path}/test_import2.csv');
    await f2.writeAsString(csv2);
    await CsvUtil.importCsvToDb(f2, db);

    final updated = (await db.readAllPatients()).firstWhere((p) => p.phone == '555');
    expect(updated.name, 'Alice Updated');
    expect(updated.age, 31);
  });
}
