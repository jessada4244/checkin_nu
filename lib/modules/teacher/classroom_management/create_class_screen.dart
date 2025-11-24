import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/teacher_service.dart';

class CreateClassScreen extends StatefulWidget {
  final int teacherId;
  const CreateClassScreen({super.key, required this.teacherId});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _subjectController = TextEditingController();
  bool _isLoading = false;

  void _createClass() async {
    if (_subjectController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final service = TeacherService();
      String key = await service.createClassroom(widget.teacherId, _subjectController.text);
      
      if (mounted) {
        // แสดง Dialog แจ้ง Key
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('สร้างวิชาสำเร็จ'),
            content: Text('รหัสสำหรับให้นิสิตเข้าห้องคือ:\n$key', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // ปิด Dialog
                  Navigator.pop(context, true); // กลับไปหน้า Dashboard พร้อมบอกว่าสำเร็จ
                },
                child: const Text('ตกลง'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างวิชาใหม่')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'ชื่อวิชา (เช่น Mobile App Dev)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createClass,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('สร้างห้องเรียน'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}