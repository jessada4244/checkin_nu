import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/classroom_model.dart';

class TeacherService {
  
  // 1. สร้างวิชาเรียนใหม่ (พร้อมระบุจำนวนที่นั่ง)
  Future<String> createClassroom(int teacherId, String subjectName, int capacity) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createClass),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teacher_id': teacherId,
        'subject_name': subjectName,
        'capacity': capacity,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['join_key']; // คืนค่า Key
    } else {
      throw Exception(data['message']);
    }
  }

  // 2. อัปเดตข้อมูลห้องเรียน (ชื่อ, จำนวน, เวลาสาย, พิกัด)
  Future<void> updateClassroom(int classId, {String? name, int? capacity, String? time, double? lat, double? lng}) async {
    final Map<String, dynamic> body = {'class_id': classId};
    
    if (name != null) body['subject_name'] = name;
    if (capacity != null) body['capacity'] = capacity;
    if (time != null) body['default_late_time'] = time;
    if (lat != null && lng != null) {
      body['lat'] = lat;
      body['lng'] = lng;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/teacher/update_classroom.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }
  }

  // 3. สร้าง Session เช็คชื่อ (รับค่าเวลาสายแบบระบุเจาะจง)
  Future<Map<String, dynamic>> createSession(int classId, String lateDatetime) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createSession),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'class_id': classId,
        'late_datetime': lateDatetime, 
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return {
        'session_id': data['session_id'],
        'late_time': data['late_time']
      };
    } else {
      throw Exception(data['message']);
    }
  }

  // 4. ดึงรายวิชาที่อาจารย์สอน
  Future<List<ClassroomModel>> getClasses(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/teacher/get_classrooms.php?teacher_id=$teacherId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> list = data['data'];
          return list.map((e) => ClassroomModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. ดึงรายการคาบเรียน (Sessions) ของวิชานั้นๆ
  Future<List<dynamic>> getSessions(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/teacher/get_sessions.php?class_id=$classId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 6. ดึงรายงานการเข้าเรียนของ Session นั้น
  Future<List<dynamic>> getAttendanceReport(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.attendanceReport}?session_id=$sessionId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}