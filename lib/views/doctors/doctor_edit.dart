import 'package:flutter/material.dart';
import '../../controllers/doctor_controller.dart';
import '../../core/utils/app_error.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/doctor.dart';
import '../../widgets/animated_background.dart';

class DoctorEdit extends StatefulWidget {
  final Doctor? doctor;
  const DoctorEdit({this.doctor, super.key});

  @override
  State<DoctorEdit> createState() => _DoctorEditState();
}

class _DoctorEditState extends State<DoctorEdit> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _spec = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _controller = DoctorController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    final doctor = widget.doctor;
    if (doctor != null) {
      _name.text = doctor.name;
      _spec.text = doctor.specialization;
      _phone.text = doctor.phone;
      _notes.text = doctor.notes ?? '';
    }
  }

  Future<void> _saveDoctor() async {
    if (!mounted || !_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final isEdit = widget.doctor != null;

    try {
      if (isEdit) {
        await _controller.updateDoctor(
          id: widget.doctor!.id!,
          name: _name.text,
          specialization: _spec.text,
          phone: _phone.text,
          notes: _notes.text,
        );
        if (!mounted) return;
        AppError.showSnackBar(
          context,
          'Doctor updated successfully',
          isError: false,
        );
      } else {
        await _controller.addDoctor(
          name: _name.text,
          specialization: _spec.text,
          phone: _phone.text,
          notes: _notes.text,
        );
        if (!mounted) return;
        AppError.showSnackBar(
          context,
          'Doctor added successfully',
          isError: false,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _spec.dispose();
    _phone.dispose();
    _notes.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.doctor != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Doctor' : 'Add Doctor',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: AnimatedBackground(
        darkMode: true,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _name,
                  label: 'Name',
                  validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _spec,
                  label: 'Specialization',
                  validator: (v) => v?.isEmpty == true ? 'Specialization is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phone,
                  label: 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notes,
                  label: 'Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: isEdit ? 'Update Doctor' : 'Add Doctor',
                  onPressed: _saveDoctor,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
