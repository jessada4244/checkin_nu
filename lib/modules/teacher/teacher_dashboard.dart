import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/classroom_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/teacher_service.dart';
import 'attendance/history_check_screen.dart';
import 'classroom_management/create_class_screen.dart';
import 'classroom_management/class_detail_screen.dart'; // Import หน้าจัดการห้องเรียน

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0; // ตัวแปรสำหรับ Navigation Bar
  UserModel? _currentUser;
  List<ClassroomModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = AuthService();
    final user = await authService.getUserSession();
    
    if (mounted) {
      setState(() {
        _currentUser = user;
      });

      if (user != null) {
        _loadClasses();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  // ฟังก์ชันดึงรายวิชาล่าสุด
  Future<void> _loadClasses() async {
    if (_currentUser == null) return;

    try {
      final service = TeacherService();
      final classes = await service.getClasses(_currentUser!.userId);
      
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 1. Tab Dashboard: แสดงรายวิชา (กดเพื่อไปหน้าจัดการ) ---
  Widget _buildDashboardTab() {
    if (_classes.isEmpty) {
      return const Center(child: Text('ยังไม่มีรายวิชา กด + เพื่อสร้าง'));
    }
    return ListView.builder(
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classroom = _classes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.class_, color: Colors.white),
            ),
            title: Text(classroom.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('รหัสเข้าห้อง: ${classroom.joinKey ?? "-"}'),
            // เปลี่ยนไอคอนเป็นลูกศร เพื่อสื่อว่ากดเข้าไปตั้งค่าข้างใน
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // กดแล้วไปหน้า "จัดการห้องเรียน" (ClassDetailScreen)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassDetailScreen(classroom: classroom),
                ),
              ).then((_) {
                // เมื่อกลับออกมา ให้รีเฟรชข้อมูล (เผื่ออาจารย์แก้ชื่อวิชา)
                _loadClasses();
              });
            },
          ),
        );
      },
    );
  }

  // --- 2. Tab Report: แสดงรายวิชา (กดเพื่อดู History) ---
  Widget _buildReportTab() {
    if (_classes.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูลวิชาสำหรับดูรายงาน'));
    }
    return ListView.builder(
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classroom = _classes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.bar_chart, color: Colors.white),
            ),
            title: Text(classroom.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('กดเพื่อดูรายงานการเข้าเรียน'),
            trailing: const Icon(Icons.history, color: AppColors.primary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryCheckScreen(
                    classId: classroom.classId,
                    subjectName: classroom.subjectName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- 3. Tab Setting: ตั้งค่าทั่วไป ---
  Widget _buildSettingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primary),
          accountName: Text('${_currentUser?.firstName ?? ""} ${_currentUser?.lastName ?? ""}'),
          accountEmail: Text('สถานะ: ${_currentUser?.role.toUpperCase()}'),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await AuthService().logout();
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'รายวิชาของฉัน';
    if (_selectedIndex == 1) appBarTitle = 'รายงานผลการเรียน';
    if (_selectedIndex == 2) appBarTitle = 'ตั้งค่าบัญชี';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboardTab(),
                _buildReportTab(),
                _buildSettingTab(),
              ],
            ),

      // ปุ่มสร้างห้อง (แสดงเฉพาะหน้า Dashboard)
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateClassScreen(teacherId: _currentUser!.userId)),
                );
                if(result == true) {
                   _loadClasses();
                }
              },
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'รายงาน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}