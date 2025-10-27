import '../controllers/db_controller.dart';
import '../models/payment.dart';

class PaymentService {
  final DBController _db = DBController.instance;

  Future<Payment> createPayment(Payment payment) =>
      _db.createPayment(payment);

  Future<List<Payment>> getAllPayments() =>
      _db.readAllPayments();

  Future<List<Payment>> getAppointmentPayments(int appointmentId) =>
      _db.readAppointmentPayments(appointmentId);

  Future<List<Payment>> getPatientPayments(int patientId) =>
      _db.readPatientPayments(patientId);

  Future<int> updatePayment(Payment payment) =>
      _db.updatePayment(payment);

  Future<Payment?> findPaymentById(int id) =>
      _db.findPaymentById(id);

  Future<int> deletePayment(int id) =>
      _db.deletePayment(id);
}