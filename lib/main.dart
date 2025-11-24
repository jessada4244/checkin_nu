import 'package:flutter/material.dart';
import 'modules/auth/login_screen.dart';
import 'modules/student/student_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkin NU',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/student': (context) => const StudentDashboard(),
      },
    );
  }
}
