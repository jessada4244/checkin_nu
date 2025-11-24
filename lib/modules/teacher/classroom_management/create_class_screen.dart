import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _capacityController = TextEditingController(); // Controller สำหรับจำนวนคน
  bool _isLoading = false;

  void _createClass() async {
    if (_subjectController.text.isEmpty || _capacityController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final service = TeacherService();
      // ส่งค่า capacity ไปด้วย
      String key = await service.createClassroom(
        widget.teacherId, 
        _subjectController.text,
        int.parse(_capacityController.text)
      );
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('สร้างวิชาสำเร็จ'),
            content: Text('รหัสวิชา: ${_subjectController.text}\nKey เข้าห้อง: $key', textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
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
            const SizedBox(height: 16),
            // ช่องกรอกจำนวน
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'จำนวนนักเรียนที่รับ (คน)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
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