import 'dart:convert';

class Patient {
  int? id;
  String name;
  int age;
  String gender;
  String phone;
  String? notes;
  String? imagePath; // single profile image path (legacy)
  List<String>? attachments; // list of attached files (images/docs)

  Patient({this.id, required this.name, required this.age, required this.gender, required this.phone, this.notes, this.imagePath, this.attachments});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'notes': notes,
      'imagePath': imagePath,
      'attachments': attachments == null ? null : jsonEncode(attachments),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> m) {
    List<String>? atts;
    if (m.containsKey('attachments') && m['attachments'] != null) {
      try {
        final decoded = jsonDecode(m['attachments'] as String);
        if (decoded is List) atts = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        // ignore parse errors
        atts = null;
      }
    }
    return Patient(
      id: m['id'] as int?,
      name: m['name'] as String,
      age: m['age'] as int,
      gender: m['gender'] as String,
      phone: m['phone'] as String,
      notes: m['notes'] as String?,
      imagePath: m['imagePath'] as String?,
      attachments: atts,
    );
  }
}
