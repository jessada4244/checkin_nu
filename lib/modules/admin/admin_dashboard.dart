import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<UserModel> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => _isLoading = true);
    try {
      final service = AdminService();
      // ดึงเฉพาะคนที่รออนุมัติ (status=pending)
      final users = await service.getUsers(onlyPending: true);
      setState(() {
        _pendingUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveUser(int userId) async {
    try {
      await AdminService().approveUser(userId);
      _loadPendingUsers(); // โหลดข้อมูลใหม่
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อนุมัติเรียบร้อย')));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectUser(int userId) async {
    try {
      await AdminService().rejectUser(userId);
      _loadPendingUsers(); // โหลดข้อมูลใหม่
    } catch (e) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: อนุมัติผู้ใช้งาน'),
        backgroundColor: Colors.black87, // สีเข้มสำหรับ Admin
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
          : _pendingUsers.isEmpty
              ? const Center(child: Text('ไม่มีผู้ใช้งานรอการอนุมัติ'))
              : ListView.builder(
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role == 'teacher' ? Colors.orange : Colors.blue,
                          child: Icon(user.role == 'teacher' ? Icons.school : Icons.person, color: Colors.white),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text('${user.role.toUpperCase()} | ${user.studentId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่มปฏิเสธ (สีแดง)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectUser(user.userId),
                            ),
                            // ปุ่มอนุมัติ (สีเขียว)
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveUser(user.userId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}