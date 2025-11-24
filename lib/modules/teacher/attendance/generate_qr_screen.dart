import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // จำเป็นต้องใช้สำหรับแปลงวันเวลา
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/teacher_service.dart';

class GenerateQrScreen extends StatefulWidget {
  final int classId;
  final String subjectName;
  final String? preCalculatedLateTime; // [แก้ไข 1] เพิ่มตัวแปรรับเวลาที่คำนวณมาแล้ว

  const GenerateQrScreen({
    super.key, 
    required this.classId, 
    required this.subjectName,
    this.preCalculatedLateTime, // [แก้ไข 1] รับค่าจาก Constructor
  });

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  int _lateMinutes = 15; // ค่าเริ่มต้นสำหรับ Slider (กรณีไม่ได้กำหนดเวลามา)
  String? _qrData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ถ้ามีการส่งเวลามาจากหน้าจัดการห้อง (ClassDetailScreen) ให้เริ่มสร้าง QR เลย
    if (widget.preCalculatedLateTime != null) {
      _startSession(usePreCalculated: true);
    }
  }

  void _startSession({bool usePreCalculated = false}) async {
    setState(() => _isLoading = true);
    try {
      final service = TeacherService();
      
      String lateTimeToSend;

      if (usePreCalculated && widget.preCalculatedLateTime != null) {
        // กรณีที่ 1: ใช้เวลาที่กำหนดมาแล้ว (เช่น 08:30 ของวันนี้)
        lateTimeToSend = widget.preCalculatedLateTime!;
      } else {
        // กรณีที่ 2: ใช้ Slider (คำนวณเวลาปัจจุบัน + นาทีที่เลือก)
        final now = DateTime.now();
        final lateDate = now.add(Duration(minutes: _lateMinutes));
        lateTimeToSend = DateFormat('yyyy-MM-dd HH:mm:ss').format(lateDate);
      }

      // [แก้ไข 2] ส่งค่าเป็น String datetime ตามที่ API ต้องการ
      final result = await service.createSession(widget.classId, lateTimeToSend);
      
      final qrJson = jsonEncode({
        "session_id": result['session_id'],
        "type": "checkin", 
        "created_at": DateTime.now().millisecondsSinceEpoch
      });

      if (mounted) {
        setState(() {
          _qrData = qrJson;
        });
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
      appBar: AppBar(title: Text('เช็คชื่อ: ${widget.subjectName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // กรณีที่ยังไม่มี QR Data
            if (_qrData == null) ...[
              
              // แสดง Slider เฉพาะเมื่อไม่ได้กำหนดเวลามาจากหน้าก่อนหน้า
              if (widget.preCalculatedLateTime == null) ...[
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
              ] else ...[
                const Text('กำลังสร้าง QR Code...', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
              ],

              if (widget.preCalculatedLateTime == null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _startSession(),
                    icon: const Icon(Icons.qr_code),
                    label: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('สร้าง QR Code เริ่มคลาส'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ),
            ] 
            // ส่วนแสดง QR Code (เหมือนเดิม)
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
                onPressed: () => setState(() {
                  _qrData = null;
                  // ถ้ามาจากหน้า Detail แล้วกดปิด Session ให้กลับไปหน้าก่อนหน้า
                  if (widget.preCalculatedLateTime != null) {
                    Navigator.pop(context);
                  }
                }),
                child: const Text('ปิด Session / จบการเช็คชื่อ'),
              )
            ]
          ],
        ),
      ),
    );
  }
}