import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import 'add_edit_patient.dart';
import '../widgets/animated_background.dart';
import '../widgets/patient_list_view.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final PatientService _service = PatientService();
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.getAll();
    _future.then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: AnimatedBackground(
        child: FutureBuilder<List<Patient>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data ?? [];
            return PatientListView(
              patients: list,
              onRefresh: () async {
                _load();
              },
              onSort: (asc) {
                // simple client-side sort
                setState(() {
                  list.sort((a, b) => asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
                });
              },
              ascending: true,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPatient()));
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
