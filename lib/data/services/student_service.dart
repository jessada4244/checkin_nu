import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/utils/device_info_tools.dart';
import '../../core/constants/utils/locations_tools.dart'; // ถ้าจะใช้ GPS
import '../models/attendance_model.dart';

class StudentService {
  
  // ฟังก์ชันเช็คชื่อ (Anti-Cheat Logic)
  Future<String> checkAttendance(int sessionId, int studentId) async {
    // 1. ดึง Device ID ของเครื่องปัจจุบัน
    String deviceId = await DeviceInfoUtil.getDeviceId();
    
    // 2. (Optional) ดึง GPS ถ้าต้องการส่งไปเช็คระยะ
    // var position = await LocationUtil.getCurrentLocation();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.scanAttendance),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'student_id': studentId,
          'device_id': deviceId, // ส่งไปให้ Server ตรวจสอบว่าเครื่องนี้ซ้ำไหม
          // 'lat': position.latitude, 
          // 'lng': position.longitude
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        return data['message']; // "เช็คชื่อสำเร็จ (present)"
      } else {
        throw Exception(data['message']); // "โกง! อุปกรณ์นี้ถูกใช้ไปแล้ว"
      }
    } catch (e) {
      rethrow;
    }
  }

  // เข้าห้องเรียนด้วย Key
  Future<void> joinClass(String joinKey, String studentId) async {
    final response = await http.post(
      Uri.parse(ApiConstants.joinClass),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'join_key': joinKey,
        'student_id': studentId,
      }),
    );
    
    final data = jsonDecode(response.body);
    if (data['status'] != 'success') throw Exception(data['message']);
  }

  // ดูประวัติการเข้าเรียน
  Future<List<AttendanceModel>> getHistory(String studentId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.studentHistory}?student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        List<dynamic> list = data['data'];
        return list.map((e) => AttendanceModel.fromJson(e)).toList();
      }
    }
    return [];
  }
}