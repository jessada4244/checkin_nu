import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // อย่าลืม import
import '../../../core/constants/app_colors.dart';
import '../../../data/services/teacher_service.dart';

class GenerateQrScreen extends StatefulWidget {
  final int classId;
  final String subjectName;

  const GenerateQrScreen({super.key, required this.classId, required this.subjectName});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  int _lateMinutes = 15; // ค่าเริ่มต้น 15 นาทีถือว่าสาย
  String? _qrData; // ข้อมูลที่จะแสดงใน QR
  bool _isLoading = false;

  void _startSession() async {
    setState(() => _isLoading = true);
    try {
      final service = TeacherService();
      // เรียก API สร้าง Session
      final result = await service.createSession(widget.classId, _lateMinutes);
      
      // สิ่งที่อยู่ใน QR Code คือ JSON String ที่มี session_id
      // เช่น {"session_id": 12, "type": "checkin"}
      final qrJson = jsonEncode({
        "session_id": result['session_id'],
        "type": "checkin", 
        "created_at": DateTime.now().millisecondsSinceEpoch // ใส่เวลาไปนิดหน่อยเพื่อให้ QR ไม่ซ้ำเดิมเป๊ะๆ
      });

      setState(() {
        _qrData = qrJson;
      });

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เช็คชื่อ: ${widget.subjectName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ส่วนตั้งค่าเวลาก่อนสร้าง QR
            if (_qrData == null) ...[
              const Text('กำหนดเวลาเข้าเรียนสาย (นาที)', style: TextStyle(fontSize: 18)),
              Slider(
                value: _lateMinutes.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '$_lateMinutes นาที',
                onChanged: (val) {
                  setState(() => _lateMinutes = val.toInt());
                },
              ),
              Text('$_lateMinutes นาที', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startSession,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('สร้าง QR Code เริ่มคลาส'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ),
            ] 
            // ส่วนแสดง QR Code
            else ...[
              const Text('ให้นิสิตสแกน QR Code นี้เพื่อเช็คชื่อ', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 300.0,
                ),
              ),
              const SizedBox(height: 20),
              const Text('⚠️ ระบบป้องกันการโกงทำงานอยู่', style: TextStyle(color: Colors.red)),
              const Text('- ห้ามเช็คชื่อซ้ำ\n- 1 เครื่อง ต่อ 1 คน', textAlign: TextAlign.center),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () => setState(() => _qrData = null),
                child: const Text('ปิด Session / สร้างใหม่'),
              )
            ]
          ],
        ),
      ),
    );
  }
}