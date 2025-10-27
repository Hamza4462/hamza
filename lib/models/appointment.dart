class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final DateTime dateTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      dateTime: DateTime.parse(map['date_time']),
      status: map['status'],
      notes: map['notes'],
    );
  }
}