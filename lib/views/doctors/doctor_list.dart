import 'package:flutter/material.dart';
import '../../controllers/doctor_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_error.dart';
import '../../core/widgets/loading_view.dart';
import '../../widgets/animated_background.dart';
import 'doctor_edit.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({super.key});

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  final _controller = DoctorController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      await _controller.loadDoctors();
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to load doctors: $e');
      }
    }
  }

  Future<void> _deleteDoctor(int id) async {
    try {
      await _controller.deleteDoctor(id);
      if (mounted) {
        AppError.showSnackBar(
          context, 
          'Doctor deleted successfully',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppError.showSnackBar(context, 'Failed to delete doctor: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctors',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DoctorEdit()),
          );
          _loadDoctors();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const LoadingView(message: 'Loading doctors...');
    }

    final doctors = _controller.doctors;
    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors yet',
              style: AppTextStyles.body1.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new doctor using the + button',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doctors.length,
          itemBuilder: (context, i) {
            final doctor = doctors[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    doctor.name.isNotEmpty ? doctor.name[0] : '?',
                    style: AppTextStyles.button,
                  ),
                ),
                title: Text(doctor.name, style: AppTextStyles.subtitle1),
                subtitle: Text(doctor.specialization, style: AppTextStyles.body2),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorEdit(doctor: doctor),
                          ),
                        );
                        _loadDoctors();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () {
                          if (doctor.id != null) {
                            _deleteDoctor(doctor.id!);
                          }
                        },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
