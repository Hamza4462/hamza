import 'package:flutter/material.dart';
import '../../controllers/payment_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_error.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../models/payment.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';
import '../../services/patient_service.dart';
import '../../widgets/animated_background.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final _paymentController = PaymentController();
  final _patientService = PatientService();
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();
  bool _isLoading = true;
  Map<int, Patient> _patients = {};
  Map<int, Doctor> _doctors = {};
  Map<int, Appointment> _appointments = {};

  Future<void> _confirmDeletePayment(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete payment'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _paymentController.deletePayment(id);
        if (!mounted) return;
        AppError.showSnackBar(context, 'Payment deleted', isError: false);
      } catch (e) {
        if (!mounted) return;
        AppError.showSnackBar(context, 'Failed to delete payment: $e');
      }
    }
  }

  Future<void> _showEditPaymentDialog(Payment payment) async {
    double amount = payment.amount;
    String method = payment.paymentMethod;
    String status = payment.status;
    String notes = payment.notes ?? '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setStateDialog) {
        return AlertDialog(
          title: const Text('Edit Payment'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: amount.toString(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: (v) => setStateDialog(() => amount = double.tryParse(v) ?? amount),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: method,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'online', child: Text('Online')),
                  ],
                  onChanged: (v) => setStateDialog(() => method = v ?? method),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'failed', child: Text('Failed')),
                  ],
                  onChanged: (v) => setStateDialog(() => status = v ?? status),
                ),
                const SizedBox(height: 8),
                TextFormField(initialValue: notes, maxLines: 3, onChanged: (v) => notes = v),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  await _paymentController.updatePaymentFull(
                    id: payment.id!,
                    amount: amount,
                    paymentMethod: method,
                    status: status,
                    notes: notes,
                  );
                  if (!mounted) return;
                  AppError.showSnackBar(context, 'Payment updated', isError: false);
                  Navigator.pop(ctx);
                } catch (e) {
                  if (mounted) AppError.showSnackBar(context, 'Failed to update payment: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _paymentController.loadPayments();
      
      // Load all related data
      final appointments = await _appointmentService.getAllAppointments();
      final patients = await _patientService.getAll();
      final doctors = await _doctorService.getAll();
      
      setState(() {
        _appointments = {for (var a in appointments) a.id!: a};
        _patients = {for (var p in patients) p.id!: p};
        _doctors = {for (var d in doctors) d.id!: d};
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to load payments: $e');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(double amount) {
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment History',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _paymentController.payments.isEmpty
                ? Center(
                    child: Text(
                      'No payments found',
                      style: AppTextStyles.subtitle1,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentController.payments.length,
                    itemBuilder: (context, index) {
                      final payment = _paymentController.payments[index];
                      final appointment = _appointments[payment.appointmentId];
                      final patient =
                          appointment != null ? _patients[appointment.patientId] : null;
                      final doctor =
                          appointment != null ? _doctors[appointment.doctorId] : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatAmount(payment.amount),
                                style: AppTextStyles.subtitle1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _getStatusColor(payment.status).withAlpha(51), // 0.2 * 255 ≈ 51
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  payment.status.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: _getStatusColor(payment.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Patient: ${patient?.name ?? "Unknown"}',
                                style: AppTextStyles.body2,
                              ),
                              Text(
                                'Doctor: Dr. ${doctor?.name ?? "Unknown"}',
                                style: AppTextStyles.body2,
                              ),
                              Text(
                                'Date: ${payment.date.day}/${payment.date.month}/${payment.date.year}',
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment Details', style: AppTextStyles.subtitle1),
                                  const SizedBox(height: 8),
                                  Text('Method: ${payment.paymentMethod.toUpperCase()}'),
                                  if (payment.transactionId != null) Text('Transaction ID: ${payment.transactionId}'),
                                  if (payment.notes?.isNotEmpty == true) ...[
                                    const SizedBox(height: 8),
                                    Text('Notes:', style: AppTextStyles.subtitle1),
                                    const SizedBox(height: 4),
                                    Text(payment.notes!),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _showEditPaymentDialog(payment),
                                        child: const Text('Edit'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                        onPressed: () => _confirmDeletePayment(payment.id!),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}