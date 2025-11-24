import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AdminService {

  // 1. ดึงรายชื่อผู้ใช้ (เลือกได้ว่าจะเอาทั้งหมด หรือเอาแค่คนที่รออนุมัติ)
  // onlyPending = true คือดึงแค่คนที่รออนุมัติ (Pending)
  Future<List<UserModel>> getUsers({bool onlyPending = false}) async {
    // สร้าง URL พร้อม Query Parameter
    String url = ApiConstants.getUsers;
    if (onlyPending) {
      url += '?status=pending';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          List<dynamic> userList = data['data'];
          // แปลง JSON List เป็น List<UserModel>
          return userList.map((json) => UserModel.fromJson(json)).toList();
        } else {
          return []; // กรณีไม่มีข้อมูล หรือ Error
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. อนุมัติผู้ใช้งาน
  Future<void> approveUser(int userId) async {
    await _manageUserStatus(userId, 1); // action 1 = approve
  }

  // 3. ไม่อนุมัติ / ลบผู้ใช้งาน
  Future<void> rejectUser(int userId) async {
    await _manageUserStatus(userId, 2); // action 2 = reject/delete
  }

  // ฟังก์ชันกลางสำหรับยิง API อนุมัติ/ลบ (Private Method)
  Future<void> _manageUserStatus(int userId, int action) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.approveUser),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'action': action,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}