import '../controllers/db_controller.dart';
import '../models/appointment.dart';

class AppointmentService {
  final DBController _db = DBController.instance;

  Future<Appointment> createAppointment(Appointment appointment) =>
      _db.createAppointment(appointment);

  Future<List<Appointment>> getAllAppointments() =>
      _db.readAllAppointments();

  Future<List<Appointment>> getPatientAppointments(int patientId) =>
      _db.readPatientAppointments(patientId);

  Future<List<Appointment>> getDoctorAppointments(int doctorId) =>
      _db.readDoctorAppointments(doctorId);

  Future<int> updateAppointment(Appointment appointment) =>
      _db.updateAppointment(appointment);

  Future<int> deleteAppointment(int id) =>
      _db.deleteAppointment(id);

  Future<Appointment?> findAppointmentById(int id) =>
      _db.findAppointmentById(id);
}