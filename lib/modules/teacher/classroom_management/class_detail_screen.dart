import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // เพิ่ม
import 'package:latlong2/latlong.dart'; // เพิ่ม
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/utils/locations_tools.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/services/teacher_service.dart';
import '../attendance/generate_qr_screen.dart';
import 'pick_location_screen.dart'; // import ไฟล์ที่สร้างใหม่

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

  void _refreshData(ClassroomModel newModel) {
    setState(() {
      _classroom = newModel;
      _isLoading = false;
    });
  }

  // ... (ฟังก์ชัน _editGeneralInfo และ _setTime คงเดิม ไม่ต้องแก้) ...
  void _editGeneralInfo() {
    final nameCtrl = TextEditingController(text: _classroom.subjectName);
    final capCtrl = TextEditingController(text: _classroom.capacity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขข้อมูลห้องเรียน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'ชื่อวิชา'),
            ),
            TextField(
              controller: capCtrl,
              decoration: const InputDecoration(labelText: 'จำนวนที่นั่ง'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await TeacherService().updateClassroom(
                _classroom.classId,
                name: nameCtrl.text,
                capacity: int.tryParse(capCtrl.text),
              );
              _refreshData(
                ClassroomModel(
                  classId: _classroom.classId,
                  subjectName: nameCtrl.text,
                  joinKey: _classroom.joinKey,
                  capacity: int.tryParse(capCtrl.text) ?? _classroom.capacity,
                  defaultLateTime: _classroom.defaultLateTime,
                  lat: _classroom.lat,
                  lng: _classroom.lng,
                ),
              );
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _setTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _classroom.defaultLateTime != null
          ? TimeOfDay(
              hour: int.parse(_classroom.defaultLateTime!.split(':')[0]),
              minute: int.parse(_classroom.defaultLateTime!.split(':')[1]),
            )
          : const TimeOfDay(hour: 8, minute: 30),
    );

    if (selectedTime != null) {
      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() => _isLoading = true);
      await TeacherService().updateClassroom(
        _classroom.classId,
        time: timeString,
      );
      _refreshData(
        ClassroomModel(
          classId: _classroom.classId,
          subjectName: _classroom.subjectName,
          joinKey: _classroom.joinKey,
          capacity: _classroom.capacity,
          defaultLateTime: timeString,
          lat: _classroom.lat,
          lng: _classroom.lng,
        ),
      );
    }
  }

  // --- Function 3: จัดการสถานที่ (ใหม่) ---
  void _openMapPicker() async {
    // เปิดหน้า PickLocationScreen และรอรับค่ากลับมา
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickLocationScreen(
          initialLat: _classroom.lat,
          initialLng: _classroom.lng,
        ),
      ),
    );

    // ถ้ามีการกดเลือกพิกัดกลับมา
    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await TeacherService().updateClassroom(
          _classroom.classId,
          lat: result.latitude,
          lng: result.longitude,
        );

        _refreshData(
          ClassroomModel(
            classId: _classroom.classId,
            subjectName: _classroom.subjectName,
            joinKey: _classroom.joinKey,
            capacity: _classroom.capacity,
            defaultLateTime: _classroom.defaultLateTime,
            lat: result.latitude,
            lng: result.longitude,
          ),
        );

        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('บันทึกพิกัดเรียบร้อย')));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // ... (ฟังก์ชัน _startCheckIn คงเดิม) ...
  void _startCheckIn() {
    if (_classroom.defaultLateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ กรุณากำหนดเวลาก่อนเริ่มคลาส'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final now = DateTime.now();
    final timeParts = _classroom.defaultLateTime!.split(':');
    final lateDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final lateDateTimeStr = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(lateDateTime);

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
      appBar: AppBar(title: const Text('จัดการห้องเรียน')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'การตั้งค่าการเช็คชื่อ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Time Card
                  _buildSettingCard(
                    icon: Icons.access_time_filled,
                    color: Colors.orange,
                    title: 'เวลาเข้าสาย',
                    value: _classroom.defaultLateTime != null
                        ? '${_classroom.defaultLateTime} น.'
                        : 'ยังไม่กำหนด',
                    onTap: _setTime,
                  ),
                  const SizedBox(height: 10),

                  // Location Card (แบบมี Map Preview)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias, // เพื่อให้ Map ไม่ล้นขอบ Card
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                          title: const Text(
                            'สถานที่ (GPS)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _classroom.lat != null
                                ? 'บันทึกแล้ว'
                                : 'ยังไม่กำหนด',
                            style: TextStyle(
                              color: _classroom.lat != null
                                  ? Colors.black87
                                  : Colors.red,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.edit_location_alt,
                            color: Colors.blue,
                          ),
                          onTap: _openMapPicker, // กดเพื่อเปิดหน้าแผนที่
                        ),

                        // แสดงแผนที่ตัวอย่าง (ถ้ามีพิกัด)
                        // ... ใน Card Location ...
                        if (_classroom.lat != null && _classroom.lng != null)
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: IgnorePointer(
                              // ป้องกันการเลื่อนแมพในหน้า Preview
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    _classroom.lat!,
                                    _classroom.lng!,
                                  ),
                                  initialZoom: 15,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          _classroom.lat!,
                                          _classroom.lng!,
                                        ),
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _startCheckIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_2, size: 28),
                      label: const Text(
                        'เริ่มเช็คชื่อ (สร้าง QR Code)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _classroom.subjectName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.vpn_key, color: Colors.grey),
                    const SizedBox(height: 5),
                    const Text(
                      'รหัสเข้าห้อง',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _classroom.joinKey ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.group, color: Colors.grey),
                    const SizedBox(height: 5),
                    const Text(
                      'จำนวนรับ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${_classroom.capacity} คน',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _editGeneralInfo,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('แก้ไขข้อมูลวิชา'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    bool isSet = value != 'ยังไม่กำหนด' && value != 'ยังไม่ตั้ง';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: TextStyle(
            color: isSet ? Colors.black87 : Colors.red,
            fontWeight: isSet ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}