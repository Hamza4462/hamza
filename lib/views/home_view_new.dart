import 'package:flutter/material.dart';
import '../services/patient_service.dart';
import '../core/extensions/color_extensions.dart';
import 'add_edit_patient.dart';
import 'doctors/doctor_list.dart';
import '../widgets/animated_background.dart';
import 'appointments/appointment_booking.dart';
import 'appointments/appointment_history.dart';
import 'payments/payment_history.dart';
import 'patient_list.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PatientService _service = PatientService();
  
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void _load() {
    _service.getAll().then((value) {
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint('Error loading patients: $error');
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
        setState(() {});
      }
    });
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor Dashboard',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage doctors and patients',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor.withAlphaFromOpacity(0.2),
                      child: Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  controller: _verticalController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Cards Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.extent(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 1.3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                // Core actions
                                _actionCard(
                                  Icons.person_add,
                                  'Add Doctor',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorList())),
                                ),
                                _actionCard(
                                  Icons.person_add_alt_1,
                                  'Add Patient',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPatient())),
                                ),
                                _actionCard(
                                  Icons.people,
                                  'Patient',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientList())),
                                ),
                                _actionCard(
                                  Icons.calendar_today,
                                  'Appointment',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentBooking())),
                                ),
                                _actionCard(
                                  Icons.history,
                                  'Appointments History',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentHistory())),
                                ),
                                _actionCard(
                                  Icons.payment,
                                  'Payment',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentHistory())),
                                ),
                                _actionCard(
                                  Icons.receipt_long,
                                  'Payments History',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistory())),
                                ),
                                _actionCard(
                                  Icons.medical_services,
                                  'Doctor Database',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorList())),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPatient()),
        ).then((_) => _load()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
