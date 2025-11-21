import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/report_tab.dart';
import 'tabs/profile_tab.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const ReportTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0984E3),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_), label: 'ห้องเรียน'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'รายงาน'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'บัญชีผู้ใช้'),
          ],
        ),
      ),
    );
  }
}