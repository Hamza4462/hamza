import 'dart:async';
import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../models/treatment.dart';
import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class DBController {
  static final DBController instance = DBController._init();
  // Database is provided by DatabaseService

  DBController._init();

  Future<Database> get database async {
    // Use the shared DatabaseService instance
    return await DatabaseService.instance.database;
  }
  // DB schema is created by DatabaseService._createTables

  Future<Patient> createPatient(Patient p) async {
    final db = await instance.database;
    final id = await db.insert('patients', p.toMap());
    p.id = id;
    return p;
  }

  Future<List<Patient>> readAllPatients() async {
    final db = await instance.database;
    final result = await db.query('patients', orderBy: 'name');
    return result.map((e) => Patient.fromMap(e)).toList();
  }

  Future<int> updatePatient(Patient p) async {
    final db = await instance.database;
    return await db.update('patients', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Doctors CRUD
  Future<Doctor> createDoctor(Doctor d) async {
    final db = await instance.database;
    final id = await db.insert('doctors', d.toMap());
      return Doctor(
        id: id,
        name: d.name,
        specialization: d.specialization,
        phone: d.phone,
        notes: d.notes,
      );
  }

  Future<List<Doctor>> readAllDoctors() async {
    final db = await instance.database;
    final result = await db.query('doctors', orderBy: 'name');
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  Future<int> updateDoctor(Doctor d) async {
    final db = await instance.database;
    return await db.update('doctors', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  Future<int> deleteDoctor(int id) async {
    final db = await instance.database;
    return await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // Appointments CRUD
  Future<Appointment> createAppointment(Appointment a) async {
    final db = await instance.database;
    final id = await db.insert('appointments', a.toMap());
    return Appointment.fromMap({...a.toMap(), 'id': id});
  }

  Future<List<Appointment>> readAllAppointments() async {
    final db = await instance.database;
    final result = await db.query('appointments', orderBy: 'date_time DESC');
    return result.map((e) => Appointment.fromMap(e)).toList();
  }

  Future<List<Appointment>> readPatientAppointments(int patientId) async {
    final db = await instance.database;
    final result = await db.query(
      'appointments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'date_time DESC',
    );
    return result.map((e) => Appointment.fromMap(e)).toList();
  }

  Future<List<Appointment>> readDoctorAppointments(int doctorId) async {
    final db = await instance.database;
    final result = await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'date_time DESC',
    );
    return result.map((e) => Appointment.fromMap(e)).toList();
  }

  Future<Appointment?> findAppointmentById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : Appointment.fromMap(result.first);
  }

  Future<int> updateAppointment(Appointment a) async {
    final db = await instance.database;
    return await db.update(
      'appointments',
      a.toMap(),
      where: 'id = ?',
      whereArgs: [a.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Payments CRUD
  Future<Payment> createPayment(Payment p) async {
    final db = await instance.database;
    final id = await db.insert('payments', p.toMap());
    return Payment.fromMap({...p.toMap(), 'id': id});
  }

  Future<List<Payment>> readAllPayments() async {
    final db = await instance.database;
    final result = await db.query('payments', orderBy: 'date DESC');
    return result.map((e) => Payment.fromMap(e)).toList();
  }

  Future<List<Payment>> readAppointmentPayments(int appointmentId) async {
    final db = await instance.database;
    final result = await db.query(
      'payments',
      where: 'appointment_id = ?',
      whereArgs: [appointmentId],
      orderBy: 'date DESC',
    );
    return result.map((e) => Payment.fromMap(e)).toList();
  }

  Future<List<Payment>> readPatientPayments(int patientId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT p.*
      FROM payments p
      JOIN appointments a ON p.appointment_id = a.id
      WHERE a.patient_id = ?
      ORDER BY p.date DESC
    ''', [patientId]);
    return result.map((e) => Payment.fromMap(e)).toList();
  }

  Future<Payment?> findPaymentById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : Payment.fromMap(result.first);
  }

  Future<int> updatePayment(Payment p) async {
    final db = await instance.database;
    return await db.update(
      'payments',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }
  
  Future<int> deletePayment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Treatments CRUD
  Future<Treatment> createTreatment(Treatment t) async {
    final db = await instance.database;
    final id = await db.insert('treatments', t.toMap());
    return Treatment(id: id, name: t.name, description: t.description, price: t.price);
  }

  Future<List<Treatment>> readAllTreatments() async {
    final db = await instance.database;
    final result = await db.query('treatments', orderBy: 'name');
    return result.map((e) => Treatment.fromMap(e)).toList();
  }

  Future<int> updateTreatment(Treatment t) async {
    final db = await instance.database;
    return await db.update('treatments', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTreatment(int id) async {
    final db = await instance.database;
    return await db.delete('treatments', where: 'id = ?', whereArgs: [id]);
  }
}
