import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/patient.dart';
import '../services/patient_service.dart';
import '../services/appointment_service.dart';
import '../services/payment_service.dart';
import '../services/treatment_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/draggable_bubble.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final PatientService _service = PatientService();
  final AppointmentService _appointmentService = AppointmentService();
  final PaymentService _paymentService = PaymentService();
  final TreatmentService _treatmentService = TreatmentService();
  List<Patient> _cached = [];
  int _appointmentsCount = 0;
  int _paymentsCount = 0;
  int _treatmentsCount = 0;
  final ScrollController _verticalController = ScrollController();
  late AnimationController _rotationController;
  final List<Map<String, double>> _bubblePositions = [];

  @override
  void initState() {
    super.initState();
    _load();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _generateBubblePositions();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _generateBubblePositions() {
    final rnd = math.Random();
    _bubblePositions.clear();
    for (int i = 0; i < 6; i++) {
      _bubblePositions.add({
        'size': rnd.nextDouble() * 80 + 40,
        'x': rnd.nextDouble() * 200,
        'y': rnd.nextDouble() * 400,
        'opacity': rnd.nextDouble() * 0.25 + 0.05,
      });
    }
  }

  Future<void> _load() async {
    try {
      final patients = await _service.getAll();
  final appointments = await _appointmentService.getAllAppointments();
  final payments = await _paymentService.getAllPayments();
  final treatments = await _treatmentService.getAll();

      if (!mounted) return;

      setState(() {
        _cached = patients;
  _appointmentsCount = appointments.length;
  _paymentsCount = payments.length;
  _treatmentsCount = treatments.length;
      });
    } catch (error) {
      debugPrint('Error loading data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
        setState(() {
          _cached = <Patient>[];
          _appointmentsCount = 0;
          _paymentsCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withAlpha(180),
              Theme.of(context).colorScheme.secondary.withAlpha(30),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // decorative circles
              Positioned(
                right: -60,
                top: 40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(28),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                top: 140,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(20),
                  ),
                ),
              ),

              // animated bubbles
              for (final bubble in _bubblePositions)
                DraggableBubble(
                  size: bubble['size']!,
                  initialX: bubble['x']!,
                  initialY: bubble['y']!,
                  opacity: bubble['opacity']!,
                  rotationController: _rotationController,
                  onTap: () {},
                ),

              SingleChildScrollView(
                controller: _verticalController,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor Dashboard',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage doctors and patients',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: width < 420 ? 2 : 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 2.1,
                        ),
                        children: [
                          DashboardCard(
                            icon: Icons.person_add_alt_1,
                            title: 'Add Doctor',
                            onTap: () => Navigator.pushNamed(context, '/add_doctor'),
                          ),
                          DashboardCard(
                            icon: Icons.person_add,
                            title: 'Add Patient',
                            onTap: () => Navigator.pushNamed(context, '/add_patient'),
                          ),
                          DashboardCard(
                            icon: Icons.people,
                            title: 'Patient',
                            count: _cached.length,
                            onTap: () => Navigator.pushNamed(context, '/patients'),
                          ),
                          DashboardCard(
                            icon: Icons.calendar_today,
                            title: 'Appointment',
                            count: _appointmentsCount,
                            onTap: () => Navigator.pushNamed(context, '/appointments'),
                          ),
                          DashboardCard(
                            icon: Icons.history_edu,
                            title: 'Appointments',
                            onTap: () => Navigator.pushNamed(context, '/appointments'),
                          ),
                          DashboardCard(
                            icon: Icons.payment,
                            title: 'Payment',
                            count: _paymentsCount,
                            onTap: () => Navigator.pushNamed(context, '/payments'),
                          ),
                          DashboardCard(
                            icon: Icons.receipt_long,
                            title: 'Payments',
                            onTap: () => Navigator.pushNamed(context, '/payments'),
                          ),
                          DashboardCard(
                            icon: Icons.medical_services,
                            title: 'Treatments',
                            count: _treatmentsCount,
                            onTap: () => Navigator.pushNamed(context, '/treatments'),
                          ),
                          for (final bubble in _bubblePositions)
                            DraggableBubble(
                              size: bubble['size']!,
                              initialX: bubble['x']!,
                              initialY: bubble['y']!,
                              opacity: bubble['opacity']!,
                              rotationController: _rotationController,
                              onTap: () {},
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Recent Patients panel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recent Patients', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                                Row(children: [
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded)),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.upload_file)),
                                  PopupMenuButton<int>(itemBuilder: (_) => [const PopupMenuItem(value: 1, child: Text('More'))]),
                                ])
                              ],
                            ),
                            const SizedBox(height: 12),
                            // search box
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: Colors.grey.withAlpha(60)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(child: TextField(decoration: const InputDecoration.collapsed(hintText: 'Search patients'))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // placeholder for recent list
                            SizedBox(
                              height: 220,
                              child: _cached.isEmpty
                                  ? Center(child: Text('No recent patients', style: Theme.of(context).textTheme.bodyMedium))
                                  : ListView.separated(
                                      itemCount: _cached.length.clamp(0, 6),
                                      separatorBuilder: (_, __) => const Divider(),
                                      itemBuilder: (ctx, i) {
                                        final p = _cached[i];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(p.name),
                                          subtitle: Text(p.phone),
                                          onTap: () => Navigator.pushNamed(context, '/patient_detail', arguments: p),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              // floating add button overlapping recent panel
              Positioned(
                right: 26,
                bottom: 26,
                child: FloatingActionButton(
                  onPressed: () => Navigator.pushNamed(context, '/add_patient'),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
