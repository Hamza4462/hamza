import '../controllers/db_controller.dart';
import '../models/treatment.dart';

class TreatmentService {
  final DBController _db = DBController.instance;

  Future<Treatment> create(Treatment t) => _db.createTreatment(t);
  Future<List<Treatment>> getAll() => _db.readAllTreatments();
  Future<int> update(Treatment t) => _db.updateTreatment(t);
  Future<int> delete(int id) => _db.deleteTreatment(id);
}
