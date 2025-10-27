import 'package:flutter/material.dart';
import '../../controllers/appointment_controller.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_error.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../services/doctor_service.dart';
import '../../services/patient_service.dart';
import '../../widgets/animated_background.dart';
import '../payments/create_payment.dart';

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({super.key});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  final _appointmentController = AppointmentController();
  final _patientService = PatientService();
  final _doctorService = DoctorService();
  bool _isLoading = true;
  Map<int, Patient> _patients = {};
  Map<int, Doctor> _doctors = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _appointmentController.loadAppointments();

      // Load all patients and doctors for reference
      final patients = await _patientService.getAll();
  final doctors = await _doctorService.getAll();

      setState(() {
        _patients = {for (var p in patients) p.id!: p};
        _doctors = {for (var d in doctors) d.id!: d};
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to load appointments: $e');
      }
    }
  }

  Future<void> _updateStatus(Appointment appointment, String status) async {
    try {
      await _appointmentController.updateAppointmentStatus(
        id: appointment.id!,
        status: status,
      );
      if (!mounted) return;
      AppError.showSnackBar(
        context,
        'Appointment status updated',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackBar(context, 'Failed to update status: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmDeleteAppointment(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete appointment'),
        content: const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _appointmentController.deleteAppointment(id);
        if (!mounted) return;
        AppError.showSnackBar(context, 'Appointment deleted', isError: false);
      } catch (e) {
        if (!mounted) return;
        AppError.showSnackBar(context, 'Failed to delete appointment: $e');
      }
    }
  }

  Future<void> _showEditAppointmentDialog(Appointment appointment) async {
    DateTime editDate = appointment.dateTime;
    TimeOfDay editTime = TimeOfDay.fromDateTime(appointment.dateTime);
    Doctor? selectedDoctor = _doctors[appointment.doctorId];
    String notes = appointment.notes ?? '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setStateDialog) {
        Future<void> pickDate() async {
          final d = await showDatePicker(
            context: ctx,
            initialDate: editDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) setStateDialog(() => editDate = DateTime(d.year, d.month, d.day, editDate.hour, editDate.minute));
        }

        Future<void> pickTime() async {
          final t = await showTimePicker(context: ctx, initialTime: editTime);
          if (t != null) setStateDialog(() => editTime = t);
        }

        return AlertDialog(
          title: const Text('Edit Appointment'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<Doctor>(
                  value: selectedDoctor,
                  items: _doctors.values.map((d) => DropdownMenuItem(value: d, child: Text('${d.name} (${d.specialization})'))).toList(),
                  onChanged: (v) => setStateDialog(() => selectedDoctor = v),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: pickDate, child: const Text('Change Date')),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: pickTime, child: const Text('Change Time')),
                const SizedBox(height: 8),
                TextFormField(initialValue: notes, maxLines: 3, onChanged: (v) => notes = v),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (selectedDoctor == null) {
                  AppError.showSnackBar(ctx, 'Select a doctor');
                  return;
                }
                final newDateTime = DateTime(editDate.year, editDate.month, editDate.day, editTime.hour, editTime.minute);
                final updated = Appointment(
                  id: appointment.id,
                  patientId: appointment.patientId,
                  doctorId: selectedDoctor!.id!,
                  dateTime: newDateTime,
                  status: appointment.status,
                  notes: notes,
                );
                try {
                  await _appointmentController.updateAppointment(updated);
                  if (!mounted) return;
                  AppError.showSnackBar(context, 'Appointment updated', isError: false);
                  Navigator.pop(ctx);
                } catch (e) {
                  if (mounted) AppError.showSnackBar(context, 'Failed to update appointment: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment History',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _appointmentController.appointments.isEmpty
                ? Center(
                    child: Text(
                      'No appointments found',
                      style: AppTextStyles.subtitle1,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appointmentController.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointmentController.appointments[index];
                      final patient = _patients[appointment.patientId];
                      final doctor = _doctors[appointment.doctorId];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            patient?.name ?? 'Unknown Patient',
                            style: AppTextStyles.subtitle1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Dr. ${doctor?.name ?? 'Unknown'} (${doctor?.specialization ?? 'Unknown'})',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} at ${TimeOfDay.fromDateTime(appointment.dateTime).format(context)}',
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(appointment.status).withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appointment.status.toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: _getStatusColor(appointment.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (appointment.notes?.isNotEmpty == true) ...[
                                    Text('Notes:', style: AppTextStyles.subtitle1),
                                    const SizedBox(height: 4),
                                    Text(appointment.notes!, style: AppTextStyles.body2),
                                    const SizedBox(height: 16),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (appointment.status == 'scheduled') ...[
                                        ElevatedButton(
                                          onPressed: () => _updateStatus(appointment, 'completed'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          child: const Text('Mark Completed'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _updateStatus(appointment, 'cancelled'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                      if (appointment.status == 'completed')
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => CreatePayment(appointment: appointment)),
                                            );
                                          },
                                          child: const Text('Create Bill'),
                                        ),
                                      ElevatedButton(
                                        onPressed: () => _showEditAppointmentDialog(appointment),
                                        child: const Text('Edit'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                        onPressed: () => _confirmDeleteAppointment(appointment.id!),
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