import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class TeacherService {
  
  // สร้างวิชาเรียนใหม่
  Future<String> createClassroom(int teacherId, String subjectName) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createClass),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teacher_id': teacherId,
        'subject_name': subjectName,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['join_key']; // คืนค่า Key ให้เอาไปโชว์นิสิต
    } else {
      throw Exception(data['message']);
    }
  }

  // สร้าง Session เช็คชื่อ (เพื่อเอา ID ไป Gen QR)
  Future<Map<String, dynamic>> createSession(int classId, int lateMinutes) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createSession),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'class_id': classId,
        'late_minutes': lateMinutes,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      // คืนค่า Session ID และเวลาสาย กลับไป
      return {
        'session_id': data['session_id'],
        'late_time': data['late_time']
      };
    } else {
      throw Exception(data['message']);
    }
  }
}