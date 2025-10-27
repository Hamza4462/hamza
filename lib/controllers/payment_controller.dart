import '../models/payment.dart';
import '../services/payment_service.dart';
import 'base_controller.dart';

class PaymentController extends BaseController {
  final PaymentService _service = PaymentService();
  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  Future<void> loadPayments() async {
    await handleAsync(() async {
      _payments = await _service.getAllPayments();
      notifyListeners();
    });
  }

  Future<void> loadAppointmentPayments(int appointmentId) async {
    await handleAsync(() async {
      _payments = await _service.getAppointmentPayments(appointmentId);
      notifyListeners();
    });
  }

  Future<void> loadPatientPayments(int patientId) async {
    await handleAsync(() async {
      _payments = await _service.getPatientPayments(patientId);
      notifyListeners();
    });
  }

  Future<void> addPayment({
    required int appointmentId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    await handleAsync(() async {
      final payment = Payment(
        appointmentId: appointmentId,
        amount: amount,
        date: DateTime.now(),
        paymentMethod: paymentMethod,
        status: 'paid',
        transactionId: transactionId,
        notes: notes,
      );
      await _service.createPayment(payment);
      await loadPayments();
    });
  }

  Future<void> updatePayment({
    required int id,
    required String status,
    String? notes,
  }) async {
    await handleAsync(() async {
      final payment = await _service.findPaymentById(id);
      if (payment == null) throw Exception('Payment not found');
      
      final updatedPayment = Payment(
        id: id,
        appointmentId: payment.appointmentId,
        amount: payment.amount,
        date: payment.date,
        paymentMethod: payment.paymentMethod,
        status: status,
        transactionId: payment.transactionId,
        notes: notes ?? payment.notes,
      );
      
      await _service.updatePayment(updatedPayment);
      await loadPayments();
    });
  }

  /// Update full payment (amount, method, status, notes)
  Future<void> updatePaymentFull({
    required int id,
    required double amount,
    required String paymentMethod,
    required String status,
    String? notes,
  }) async {
    await handleAsync(() async {
      final payment = await _service.findPaymentById(id);
      if (payment == null) throw Exception('Payment not found');

      final updatedPayment = Payment(
        id: id,
        appointmentId: payment.appointmentId,
        amount: amount,
        date: payment.date,
        paymentMethod: paymentMethod,
        status: status,
        transactionId: payment.transactionId,
        notes: notes ?? payment.notes,
      );

      await _service.updatePayment(updatedPayment);
      await loadPayments();
    });
  }

  Future<void> deletePayment(int id) async {
    await handleAsync(() async {
      await _service.deletePayment(id);
      await loadPayments();
    });
  }

  Payment? findPaymentById(int id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}