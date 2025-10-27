import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_app2/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  
  setUpAll(() {
    // Set global database factory
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

