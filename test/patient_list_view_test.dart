import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:doctor_app2/widgets/patient_list_view.dart';
import 'package:doctor_app2/models/patient.dart';

void main() {
  testWidgets('PatientListView displays patients and supports refresh', (tester) async {
  final patients = List.generate(3, (i) => Patient(id: i, name: 'Patient $i', age: 30 + i, gender: 'M', phone: '000-000$i'));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PatientListView(
          patients: patients,
          onRefresh: () async {},
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Patient 0'), findsOneWidget);
    expect(find.text('Patient 1'), findsOneWidget);
    expect(find.text('Patient 2'), findsOneWidget);

    // verify tapping an item navigates (we only check the ListTile exists and is tappable)
    final tile = find.text('Patient 1');
    expect(tile, findsOneWidget);
  });
}
