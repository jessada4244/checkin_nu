import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/classroom_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/teacher_service.dart';
import 'attendance/generate_qr_screen.dart'; // เดี๋ยวสร้าง
import 'classroom_management/create_class_screen.dart'; // เดี๋ยวสร้าง

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  UserModel? _currentUser;
  List<ClassroomModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // โหลดข้อมูล User และ รายวิชา
  Future<void> _loadData() async {
    final authService = AuthService();
    final user = await authService.getUserSession();
    
    // TODO: ใน TeacherService ต้องมีฟังก์ชัน getClassesByTeacherId (ตอนนี้สมมติว่าดึงมาได้ หรือ Mock ไปก่อน)
    // เพื่อความรวดเร็ว ผมจะข้ามส่วนดึงรายวิชาไปก่อน โดยเน้นที่การสร้างวิชาใหม่แล้วเห็นผล
    
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายวิชาที่สอน'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.class_, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ยังไม่มีรายวิชา กด + เพื่อสร้าง'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classroom = _classes[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(classroom.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('รหัสเข้าห้อง: ${classroom.joinKey}'),
                        trailing: const Icon(Icons.qr_code, color: AppColors.primary),
                        onTap: () {
                          // กดแล้วไปหน้าสร้าง QR Code สำหรับเช็คชื่อ
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenerateQrScreen(classId: classroom.classId, subjectName: classroom.subjectName),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // ไปหน้าสร้างห้องเรียน แล้วรอผลลัพธ์กลับมา
           final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateClassScreen(teacherId: _currentUser!.userId)),
          );
          
          // ถ้าสร้างเสร็จให้โหลดข้อมูลใหม่ (ในที่นี้อาจจะต้องเขียน Logic ดึงข้อมูลเพิ่ม)
          if(result == true) {
             // _loadClasses(); 
          }
        },
      ),
    );
  }
}