import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import '../models/patient.dart';
import 'dart:convert';
import '../controllers/db_controller.dart';

class CsvUtil {
  static String patientsToCsv(List<Patient> list) {
  final rows = <List<dynamic>>[];
    rows.add(['id', 'name', 'age', 'gender', 'phone', 'notes', 'imagePath', 'attachments']);
    for (final pt in list) {
      rows.add([
        pt.id ?? '',
        pt.name,
        pt.age,
        pt.gender,
        pt.phone,
        pt.notes ?? '',
        pt.imagePath ?? '',
        pt.attachments == null ? '' : jsonEncode(pt.attachments),
      ]);
    }
    // csv package v5 provides const ListToCsvConverter as CsvCodec uses ListToCsvConverter
    return const ListToCsvConverter().convert(rows);
  }

  static Future<File> saveCsv(String content, String filename) async {
    final dir = Directory.systemTemp;
    final file = File(p.join(dir.path, filename));
    return file.writeAsString(content);
  }

  static Future<void> importCsvToDb(File file, DBController db) async {
    final content = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(content, shouldParseNumbers: false);
    if (rows.isEmpty) return;
    // header assumed in first row
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    for (final r in rows.skip(1)) {
      if (r.isEmpty) continue;
      final map = <String, String>{};
      for (int i = 0; i < r.length && i < header.length; i++) {
        map[header[i]] = r[i].toString();
      }
      final name = map['name'] ?? '';
      final age = int.tryParse(map['age'] ?? '') ?? 0;
      final gender = map['gender'] ?? '';
      final phone = map['phone'] ?? '';
      final notes = (map['notes'] ?? '').isEmpty ? null : map['notes'];
      final imagePath = (map['imagepath'] ?? '').isEmpty ? null : map['imagepath'];
      final attachmentsJson = (map['attachments'] ?? '');
      List<String>? attachments;
      if (attachmentsJson.isNotEmpty) {
        try {
          final dec = jsonDecode(attachmentsJson);
          if (dec is List) attachments = dec.map((e) => e.toString()).toList();
        } catch (_) {}
      }

      // Dedup/update: match by phone if available, otherwise insert new
      final existing = await db.readAllPatients();
      Patient? match;
      if (phone.isNotEmpty) {
        try {
          match = existing.firstWhere((e) => e.phone == phone);
        } catch (_) {
          match = null;
        }
      }
      if (match != null) {
        // update existing
        match.name = name;
        match.age = age;
        match.gender = gender;
        match.notes = notes;
        match.imagePath = imagePath;
        match.attachments = attachments ?? match.attachments;
        await db.updatePatient(match);
      } else {
        final patient = Patient(name: name, age: age, gender: gender, phone: phone, notes: notes, imagePath: imagePath, attachments: attachments);
        await db.createPatient(patient);
      }
    }
  }
}
