import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/utils/locations_tools.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/services/teacher_service.dart';
import '../attendance/generate_qr_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassroomModel classroom;
  const ClassDetailScreen({super.key, required this.classroom});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late ClassroomModel _classroom;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classroom = widget.classroom;
  }

  // 1. ตั้งค่าห้อง (แก้ไขชื่อ, จำนวน) และอัปเดตตัวแปรทันที
  void _editSettings() {
    final nameCtrl = TextEditingController(text: _classroom.subjectName);
    final capCtrl = TextEditingController(text: _classroom.capacity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ตั้งค่าห้องเรียน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ชื่อวิชา')),
            TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'จำนวนนักศึกษา'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              // อัปเดต Server
              await TeacherService().updateClassroom(_classroom.classId, 
                name: nameCtrl.text, 
                capacity: int.tryParse(capCtrl.text)
              );

              // [แก้ไข] อัปเดตตัวแปร Local ทันที เพื่อให้หน้าจอเปลี่ยน
              setState(() {
                _isLoading = false;
                _classroom = ClassroomModel(
                  classId: _classroom.classId,
                  subjectName: nameCtrl.text, // ค่าใหม่
                  joinKey: _classroom.joinKey,
                  capacity: int.tryParse(capCtrl.text) ?? _classroom.capacity, // ค่าใหม่
                  defaultLateTime: _classroom.defaultLateTime,
                  lat: _classroom.lat,
                  lng: _classroom.lng,
                );
              });
              
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกแล้ว')));
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // 2. กำหนดเวลา (แก้ไขให้อัปเดตตัวแปรทันที)
  void _setTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      // แปลงเป็น format HH:mm เช่น 08:30
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      final timeString = '$hour:$minute';

      setState(() => _isLoading = true);
      
      // อัปเดต Server
      await TeacherService().updateClassroom(_classroom.classId, time: timeString);
      
      // [แก้ไข] อัปเดตตัวแปร Local ทันที
      setState(() {
        _isLoading = false;
        // สร้าง Object ใหม่โดยใช้ค่าเดิม + เวลาใหม่
        _classroom = ClassroomModel(
          classId: _classroom.classId,
          subjectName: _classroom.subjectName,
          joinKey: _classroom.joinKey,
          capacity: _classroom.capacity,
          defaultLateTime: timeString, // <--- อัปเดตตรงนี้
          lat: _classroom.lat,
          lng: _classroom.lng,
        );
      });
      
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกเวลาสาย: $timeString น.')));
    }
  }

  // 3. กำหนดสถานที่ (แก้ไขให้อัปเดตตัวแปรทันที)
  void _setLocation() async {
    setState(() => _isLoading = true);
    try {
      Position? position = await LocationUtil.getCurrentLocation();
      if (position != null) {
        // อัปเดต Server
        await TeacherService().updateClassroom(_classroom.classId, lat: position.latitude, lng: position.longitude);
        
        // [แก้ไข] อัปเดตตัวแปร Local ทันที
        setState(() {
          _classroom = ClassroomModel(
            classId: _classroom.classId,
            subjectName: _classroom.subjectName,
            joinKey: _classroom.joinKey,
            capacity: _classroom.capacity,
            defaultLateTime: _classroom.defaultLateTime,
            lat: position.latitude, // ค่าใหม่
            lng: position.longitude, // ค่าใหม่
          );
        });

        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกตำแหน่งปัจจุบันเรียบร้อย')));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 4. เริ่มเช็คชื่อ
  void _startCheckIn() {
    // ตรวจสอบว่าตัวแปร _classroom มีเวลาหรือยัง
    if (_classroom.defaultLateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากำหนดเวลาก่อนเริ่มคลาส'), backgroundColor: Colors.red));
      return;
    }

    // คำนวณ DateTime ของวันนี้ + เวลาที่ตั้งไว้
    final now = DateTime.now();
    final timeParts = _classroom.defaultLateTime!.split(':');
    final lateDateTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
    
    // แปลงเป็น String เพื่อส่ง API
    final lateDateTimeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(lateDateTime);

    // ไปหน้า Generate QR พร้อมส่งเวลาที่คำนวณแล้วไป
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenerateQrScreen(
          classId: _classroom.classId, 
          subjectName: _classroom.subjectName,
          preCalculatedLateTime: lateDateTimeStr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_classroom.subjectName)),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : 
      GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(Icons.settings, 'ตั้งค่าห้อง\n(${_classroom.capacity} คน)', _editSettings),
          _buildMenuCard(Icons.access_time, 'กำหนดเวลา\n${_classroom.defaultLateTime ?? "ยังไม่ตั้ง"}', _setTime),
          _buildMenuCard(Icons.location_on, 'กำหนดสถานที่\n${_classroom.lat != null ? "บันทึกแล้ว" : "ยังไม่ตั้ง"}', _setLocation),
          _buildMenuCard(Icons.qr_code_2, 'เริ่มเช็คชื่อ', _startCheckIn, color: AppColors.primary, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, VoidCallback onTap, {Color? color, bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isHighlight ? color : Colors.white,
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: isHighlight ? Colors.white : (color ?? AppColors.primary)),
            const SizedBox(height: 10),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.white : Colors.black87
              )
            ),
          ],
        ),
      ),
    );
  }
}