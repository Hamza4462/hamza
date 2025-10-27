import 'package:flutter/material.dart';
import '../../controllers/payment_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_error.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../services/doctor_service.dart';
import '../../services/patient_service.dart';
import '../../widgets/animated_background.dart';

class CreatePayment extends StatefulWidget {
  final Appointment appointment;

  const CreatePayment({required this.appointment, super.key});

  @override
  State<CreatePayment> createState() => _CreatePaymentState();
}

class _CreatePaymentState extends State<CreatePayment> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  final _paymentController = PaymentController();
  final _patientService = PatientService();
  final _doctorService = DoctorService();

  String _paymentMethod = 'cash';
  bool _isLoading = true;
  Patient? _patient;
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final patient = (await _patientService.getAll()).firstWhere(
        (p) => p.id == widget.appointment.patientId,
      );
      final doctor = (await _doctorService.getAll()).firstWhere(
        (d) => d.id == widget.appointment.doctorId,
      );

      setState(() {
        _patient = patient;
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to load data: $e');
      }
    }
  }

  Future<void> _createPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _paymentController.addPayment(
        appointmentId: widget.appointment.id!,
        amount: double.parse(_amount.text),
        paymentMethod: _paymentMethod,
        notes: _notes.text,
      );

      if (!mounted) return;
      AppError.showSnackBar(
        context,
        'Payment created successfully',
        isError: false,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackBar(context, 'Failed to create payment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Payment',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appointment Details',
                                  style: AppTextStyles.subtitle1.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Patient: ${_patient?.name ?? "Unknown"}'),
                                Text(
                                    'Doctor: Dr. ${_doctor?.name ?? "Unknown"} (${_doctor?.specialization ?? "Unknown"})'),
                                Text(
                                    'Date: ${widget.appointment.dateTime.day}/${widget.appointment.dateTime.month}/${widget.appointment.dateTime.year}'),
                                Text(
                                    'Time: ${TimeOfDay.fromDateTime(widget.appointment.dateTime).format(context)}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _amount,
                          label: 'Amount',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v?.isEmpty == true) {
                              return 'Amount is required';
                            }
                            if (double.tryParse(v!) == null) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          initialValue: _paymentMethod,
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'card',
                              child: Text('Card'),
                            ),
                            DropdownMenuItem(
                              value: 'online',
                              child: Text('Online'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _paymentMethod = value);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _notes,
                          label: 'Notes',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Create Payment',
                          onPressed: _createPayment,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}