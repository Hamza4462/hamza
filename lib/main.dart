import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'utils/app_constants.dart';
import 'views/splash_view.dart';
import 'views/patient_list.dart';
import 'views/appointments/appointment_history.dart';
import 'views/payments/payment_history.dart';
import 'views/treatments/treatments_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseService.instance.database;
    runApp(const MyApp());
  } catch (e, st) {
    debugPrint('Database initialization error: $e');
    debugPrint('$st');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Initialization error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.button,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SplashView(),
      routes: {
        '/patients': (_) => const PatientList(),
        '/appointments': (_) => const AppointmentHistory(),
        '/payments': (_) => const PaymentHistory(),
        '/treatments': (_) => const TreatmentsView(),
      },
    );
  }
}
