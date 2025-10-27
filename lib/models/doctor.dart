class Doctor {
  final int? id;
  final String name;
  final String specialization;
  final String phone;
  final String? notes;

  Doctor({
    this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'specialization': specialization,
    'phone': phone,
    'notes': notes,
  };

  factory Doctor.fromMap(Map<String, dynamic> m) => Doctor(
    id: m['id'] as int?,
    name: m['name'] as String,
    specialization: m['specialization'] as String,
    phone: m['phone'] as String,
    notes: m['notes'] as String?,
  );
}
