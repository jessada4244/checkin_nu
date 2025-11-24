import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/student_service.dart';
import 'scan_qr_screen.dart'; // เดี๋ยวสร้างไฟล์นี้

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  UserModel? _currentUser;
  List<AttendanceModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = AuthService();
    final studentService = StudentService();
    
    final user = await authService.getUserSession();
    
    if (user != null) {
      // ดึงประวัติการเข้าเรียน
      final history = await studentService.getHistory(user.userId.toString()); // ใน DB อาจใช้ user_id เชื่อม

      if (mounted) {
        setState(() {
          _currentUser = user;
          _history = history;
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันใส่รหัสเข้าห้องเรียน
  void _showJoinClassDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เข้าห้องเรียน'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(
            labelText: 'กรอกรหัสวิชา (6 หลัก)',
            hintText: 'เช่น AB12CD',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text.isNotEmpty) {
                Navigator.pop(context);
                try {
                  await StudentService().joinClass(keyController.text, _currentUser!.studentId!);
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เข้าห้องเรียนสำเร็จ!')));
                } catch (e) {
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('นิสิต: เช็คชื่อ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_work),
            tooltip: 'Join Class',
            onPressed: _showJoinClassDialog,
          ),
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
          : Column(
              children: [
                // Header ส่วนแสดงชื่อ
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.primary.withOpacity(0.1),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สวัสดี, ${_currentUser?.firstName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('รหัสนิสิต: ${_currentUser?.studentId}'),
                    ],
                  ),
                ),
                
                // ส่วนประวัติการเข้าเรียน
                Expanded(
                  child: _history.isEmpty
                      ? const Center(child: Text('ยังไม่มีประวัติการเข้าเรียน'))
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return ListTile(
                              leading: Icon(
                                item.status == 'present' ? Icons.check_circle : Icons.warning,
                                color: item.status == 'present' ? AppColors.success : AppColors.warning,
                              ),
                              title: Text(item.subjectName),
                              subtitle: Text(item.scanTime.toString()), // ใน core มี date_formatter เอามาใช้ได้
                              trailing: Text(
                                item.status.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.status == 'present' ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.qr_code_scanner, size: 36, color: Colors.black),
          onPressed: () {
            // ไปหน้าสแกน QR
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanQrScreen()),
            ).then((_) => _loadData()); // กลับมาแล้วโหลดข้อมูลใหม่
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}