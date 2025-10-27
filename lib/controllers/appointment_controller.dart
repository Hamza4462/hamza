import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'base_controller.dart';

class AppointmentController extends BaseController {
  final AppointmentService _service = AppointmentService();
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    await handleAsync(() async {
      _appointments = await _service.getAllAppointments();
      notifyListeners();
    });
  }

  Future<void> loadPatientAppointments(int patientId) async {
    await handleAsync(() async {
      _appointments = await _service.getPatientAppointments(patientId);
      notifyListeners();
    });
  }

  Future<void> loadDoctorAppointments(int doctorId) async {
    await handleAsync(() async {
      _appointments = await _service.getDoctorAppointments(doctorId);
      notifyListeners();
    });
  }

  Future<void> addAppointment({
    required int patientId,
    required int doctorId,
    required DateTime dateTime,
    String? notes,
  }) async {
    await handleAsync(() async {
      final appointment = Appointment(
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        status: 'scheduled',
        notes: notes,
      );
      await _service.createAppointment(appointment);
      await loadAppointments();
    });
  }

  Future<void> updateAppointmentStatus({
    required int id,
    required String status,
  }) async {
    await handleAsync(() async {
      final appointment = await _service.findAppointmentById(id);
      if (appointment == null) throw Exception('Appointment not found');
      
      final updatedAppointment = Appointment(
        id: id,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        dateTime: appointment.dateTime,
        status: status,
        notes: appointment.notes,
      );
      
      await _service.updateAppointment(updatedAppointment);
      await loadAppointments();
    });
  }

  /// Update whole appointment (date/time, doctor, notes)
  Future<void> updateAppointment(Appointment appointment) async {
    await handleAsync(() async {
      await _service.updateAppointment(appointment);
      await loadAppointments();
    });
  }

  Future<void> deleteAppointment(int id) async {
    await handleAsync(() async {
      await _service.deleteAppointment(id);
      await loadAppointments();
    });
  }

  Appointment? findAppointmentById(int id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}