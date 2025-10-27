import '../models/doctor.dart';
import '../services/doctor_service.dart';
import 'base_controller.dart';

class DoctorController extends BaseController {
  final DoctorService _service = DoctorService();
  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  Future<void> loadDoctors() async {
    await handleAsync(() async {
      _doctors = await _service.getAll();
      notifyListeners();
    });
  }

  Future<void> addDoctor({
    required String name,
    required String specialization,
    required String phone,
    String? notes,
  }) async {
    await handleAsync(() async {
      final doctor = Doctor(
        name: name.trim(),
        specialization: specialization.trim(),
        phone: phone.trim(),
        notes: notes?.trim(),
      );
        final newDoctor = await _service.addDoctor(doctor);
        _doctors.add(newDoctor);
      await loadDoctors(); // Refresh the list
    });
  }

  Future<void> updateDoctor({
      required int id,
    required String name,
    required String specialization,
    required String phone,
    String? notes,
  }) async {
    await handleAsync(() async {
      final doctor = Doctor(
        id: id,
        name: name.trim(),
        specialization: specialization.trim(),
        phone: phone.trim(),
        notes: notes?.trim(),
      );
      await _service.update(doctor);
      await loadDoctors(); // Refresh the list
    });
  }

    Future<void> deleteDoctor(int id) async {
    await handleAsync(() async {
      await _service.delete(id);
      await loadDoctors(); // Refresh the list
    });
  }

    Doctor? findDoctorById(int id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}