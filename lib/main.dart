import 'package:flutter/material.dart';
import 'screens/main_navigator.dart';

void main() {
  runApp(const CheckInTeacherApp());
}

class CheckInTeacherApp extends StatelessWidget {
  const CheckInTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Check-in Classroom',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: const Color(0xFF0984E3),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0984E3),
          secondary: const Color(0xFF00B894),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigator(),
    );
  }
}