import '../controllers/db_controller.dart';
import '../models/patient.dart';
import '../utils/csv_util.dart';

import 'dart:io';

import '../utils/file_manager.dart';

class PatientService {
  final DBController _db = DBController.instance;

  Future<Patient> create(Patient p) => _db.createPatient(p);
  Future<List<Patient>> getAll() => _db.readAllPatients();
  Future<int> update(Patient p) => _db.updatePatient(p);
  Future<int> delete(int id) => _db.deletePatient(id);

  Future<File?> exportCsv() async {
    final list = await getAll();
    final csv = CsvUtil.patientsToCsv(list);
    return await CsvUtil.saveCsv(csv, 'patients_export.csv');
  }

  Future<void> importCsvFromFile() async {
    final path = await FileManager.pickFile();
    if (path == null) return;
    await CsvUtil.importCsvToDb(File(path), _db);
  }
}
