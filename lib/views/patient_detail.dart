import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/file_manager.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientDetail extends StatefulWidget {
  final Patient patient;

  const PatientDetail({required this.patient, super.key});

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  final PatientService _service = PatientService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patient.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.patient.imagePath != null) ...[
                SizedBox(
                  height: 180,
                  child: Image.file(File(widget.patient.imagePath!)),
                ),
                const SizedBox(height: 12),
              ],
              Text('Age: ${widget.patient.age}'),
              Text('Gender: ${widget.patient.gender}'),
              Text('Phone: ${widget.patient.phone}'),
              const SizedBox(height: 12),
              Text('Notes:'),
              Text(widget.patient.notes ?? '-'),
              const SizedBox(height: 12),
              if (widget.patient.attachments != null && widget.patient.attachments!.isNotEmpty) ...[
                const Text('Attachments:'),
                const SizedBox(height: 6),
                for (final a in widget.patient.attachments!)
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(a.split(RegExp(r'[\\/]')).last),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () async {
                            await OpenFilex.open(a);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.save_alt),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final cp = await FileManager.saveCopyToTemp(a);
                            if (mounted && cp != null) {
                              messenger.showSnackBar(SnackBar(content: Text('Saved copy to $cp')));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (widget.patient.id != null) await _service.delete(widget.patient.id!);
                  if (!navigator.mounted) return;
                  navigator.pop();
                },
                child: const Text('Delete Patient'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
