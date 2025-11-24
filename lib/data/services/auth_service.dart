import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/utils/device_info_tools.dart';
import '../models/user_model.dart';

class AuthService {
  // ฟังก์ชัน Login
  Future<UserModel?> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        UserModel user = UserModel.fromJson(data['data']);
        await _saveUserSession(user); // บันทึกลงเครื่อง
        return user;
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      rethrow; // ส่ง Error ไปให้หน้า UI จัดการต่อ
    }
  }

  // ฟังก์ชัน Register (พร้อมส่ง Device ID ไปผูกมัด)
  Future<void> register(String studentId, String password, String firstName, String lastName, String phone) async {
    // ดึง Device ID เพื่อผูกกับบัญชีทันทีที่สมัคร (Anti-Cheat)
    String deviceId = await DeviceInfoUtil.getDeviceId();

    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': studentId,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'device_id': deviceId, 
        'role': 'student', // Default เป็นนิสิต
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }
  }

  // บันทึกข้อมูลลงเครื่อง (Local Storage)
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // ดึงข้อมูล User ที่ Login ค้างไว้
  Future<UserModel?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}