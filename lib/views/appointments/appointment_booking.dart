import 'package:flutter/material.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_error.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';
import '../../widgets/animated_background.dart';

class AppointmentBooking extends StatefulWidget {
  const AppointmentBooking({super.key});

  @override
  State<AppointmentBooking> createState() => _AppointmentBookingState();
}

class _AppointmentBookingState extends State<AppointmentBooking> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _appointmentController = AppointmentController();
  final _doctorController = DoctorController();
  final _patientService = PatientService();

  Patient? _selectedPatient;
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      await _doctorController.loadDoctors();
      setState(() {});
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to load doctors: $e');
      }
    }
  }

  Future<void> _searchPatient() async {
    if (_phone.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final patients = await _patientService.getAll();
      final patient = patients.firstWhere(
        (p) => p.phone == _phone.text,
        orElse: () => throw Exception('Patient not found'),
      );
      setState(() => _selectedPatient = patient);
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Patient not found');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedPatient == null ||
        _selectedDoctor == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await _appointmentController.addAppointment(
        patientId: _selectedPatient!.id!,
        doctorId: _selectedDoctor!.id!,
        dateTime: dateTime,
        notes: _notes.text,
      );

      if (!mounted) return;
      AppError.showSnackBar(
        context,
        'Appointment booked successfully',
        isError: false,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackBar(context, 'Failed to book appointment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _phone,
                          label: 'Patient Phone',
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Phone is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        text: 'Search',
                        onPressed: _searchPatient,
                        isLoading: _isLoading,
                        width: 100,
                      ),
                    ],
                  ),
                  if (_selectedPatient != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Details',
                              style: AppTextStyles.subtitle1.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Name: ${_selectedPatient!.name}'),
                            Text('Age: ${_selectedPatient!.age}'),
                            Text('Gender: ${_selectedPatient!.gender}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<Doctor>(
                      decoration: InputDecoration(
                        labelText: 'Select Doctor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      initialValue: _selectedDoctor,
                      items: _doctorController.doctors.map((doctor) {
                        return DropdownMenuItem<Doctor>(
                          value: doctor,
                          child: Text('${doctor.name} (${doctor.specialization})'),
                        );
                      }).toList(),
                      onChanged: (doctor) {
                        setState(() => _selectedDoctor = doctor);
                      },
                      validator: (v) =>
                          v == null ? 'Please select a doctor' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: _selectedDate == null
                                ? 'Select Date & Time'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedTime?.format(context) ?? ""}',
                            onPressed: _selectDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _notes,
                      label: 'Notes',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Book Appointment',
                      onPressed: _bookAppointment,
                      isLoading: _isLoading,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}