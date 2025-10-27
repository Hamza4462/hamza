import '../controllers/db_controller.dart';
import '../models/doctor.dart';

class DoctorService {
  final DBController _db = DBController.instance;

  Future<Doctor> addDoctor(Doctor d) => _db.createDoctor(d);
  Future<List<Doctor>> getAll() => _db.readAllDoctors();
  Future<int> update(Doctor d) => _db.updateDoctor(d);
  Future<int> delete(int id) => _db.deleteDoctor(id);
}
