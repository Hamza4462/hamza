import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../constants/custom_text_fields.dart';
import '../utils/file_manager.dart';
import '../widgets/animated_background.dart';

class AddEditPatient extends StatefulWidget {
  final Patient? patient;
  const AddEditPatient({this.patient, super.key});

  @override
  State<AddEditPatient> createState() => _AddEditPatientState();
}

class _AddEditPatientState extends State<AddEditPatient> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final PatientService _service = PatientService();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  String? _imagePath;
  List<String> _attachments = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      _name.text = p.name;
      _age.text = p.age.toString();
      _gender.text = p.gender;
      _phone.text = p.phone;
      _notes.text = p.notes ?? '';
      _imagePath = p.imagePath;
      _attachments = p.attachments ?? [];
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _name.dispose();
    _age.dispose();
    _gender.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Patient' : 'Add Patient')),
      body: AnimatedBackground(
        darkMode: true,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _verticalController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    if (_imagePath != null)
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(_imagePath!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _imagePath = null),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Form Fields - In a Card for better organization
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _name,
                              decoration: AppTextField.outline('Patient Name'),
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormField(
                                      controller: _age,
                                      decoration: AppTextField.outline('Age'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: TextFormField(
                                      controller: _gender,
                                      decoration: AppTextField.outline('Gender'),
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                              TextFormField(
                                controller: _phone,
                                decoration: AppTextField.outline('Phone'),
                                keyboardType: TextInputType.phone,
                                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                              ),
                            const SizedBox(height: 16),
                              TextFormField(
                                controller: _notes,
                                decoration: AppTextField.outline('Notes'),
                                maxLines: 3,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Attachments Section - In a Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attachments',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final a in _attachments)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(a.split(RegExp(r'[\\/]')).last),
                                        onDeleted: () {
                                          setState(() => _attachments.remove(a));
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Add Photo'),
                          onPressed: () async {
                            final image = await FileManager.pickImage();
                            if (image != null) {
                              setState(() => _imagePath = image);
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files'),
                          onPressed: () async {
                            final files = await FileManager.pickFiles();
                            if (files.isNotEmpty) {
                              setState(() => _attachments.addAll(files));
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() => _isSaving = true);
                            try {
                              final patient = Patient(
                                id: widget.patient?.id,
                                name: _name.text,
                                age: int.parse(_age.text),
                                gender: _gender.text,
                                phone: _phone.text,
                                notes: _notes.text,
                                imagePath: _imagePath,
                                attachments: _attachments,
                              );

                              if (isEdit) {
                                await _service.update(patient);
                              } else {
                                await _service.create(patient);
                              }

                              if (!mounted) return;
                              _onSuccessfulSave();
                            } catch (e) {
                              if (!mounted) return;
                              _onSaveError(e);
                            }
                          }
                        },
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : Text(isEdit ? 'Update Patient' : 'Save Patient'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSuccessfulSave() {
    Navigator.pop(context);
  }

  void _onSaveError(dynamic error) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}