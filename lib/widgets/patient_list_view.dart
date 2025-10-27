import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient.dart';

typedef SortCallback = void Function(bool ascending);

class PatientListView extends StatelessWidget {
  final List<Patient> patients;
  final Future<void> Function()? onRefresh;
  final SortCallback? onSort;
  final bool ascending;

  const PatientListView({
    super.key,
    required this.patients,
    this.onRefresh,
    this.onSort,
    this.ascending = true,
  });

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return const Center(child: Text('No patients'));
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: patients.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final p = patients[index];
          return ListTile(
            leading: p.imagePath != null
                ? CircleAvatar(backgroundImage: FileImage(File(p.imagePath!)))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(p.name),
            subtitle: Text(p.phone),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.pushNamed(context, '/add_edit_patient', arguments: p).then((_) {
                    if (onRefresh != null) onRefresh!();
                  });
                } else if (value == 'detail') {
                  Navigator.pushNamed(context, '/patient_detail', arguments: p);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'detail', child: Text('Detail')),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, '/patient_detail', arguments: p),
          );
        },
      ),
    );
  }
}
