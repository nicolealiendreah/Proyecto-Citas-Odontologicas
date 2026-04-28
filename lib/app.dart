import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/history_screen.dart';
import 'screens/manage_appointments_screen.dart';
import 'screens/confirm_appointment_screen.dart';

class MyDentApp extends StatelessWidget {
  const MyDentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYDENT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/register',
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/appointments': (_) => const AppointmentsScreen(),
        '/history': (_) => const HistoryScreen(),
        '/manage-appointments': (_) => const ManageAppointmentsScreen(),
        '/confirm-appointment': (_) => const ConfirmAppointmentScreen(),
      },
    );
  }
}
