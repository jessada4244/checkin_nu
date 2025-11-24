class ApiConstants {
  // TODO: เปลี่ยน IP ตามสภาพแวดล้อมที่ใช้
  // Android Emulator ใช้ 'http://10.0.2.2/server_api'
  // iOS Simulator / Web ใช้ 'http://localhost/server_api'
  // เครื่องจริง ใช้ IP ของเครื่อง Mac เช่น 'http://192.168.1.45/server_api'

  static const String baseUrl = 'http://localhost/server_api';

  // Auth
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register.php';

  // Student
  static const String scanAttendance = '$baseUrl/student/scan_attendance.php';
  static const String joinClass = '$baseUrl/student/join_class.php';
  static const String studentHistory = '$baseUrl/student/get_history.php';

  // Teacher
  static const String createClass = '$baseUrl/teacher/create_classroom.php';
  static const String createSession = '$baseUrl/teacher/create_session.php';
  static const String attendanceReport =
      '$baseUrl/teacher/get_attendance_report.php';

  // Admin
  // ในไฟล์ api_constants.dart ส่วน Admin
  static const String getUsers =
      '$baseUrl/admin/get_users.php'; // เพิ่มบรรทัดนี้

  static const String approveUser = '$baseUrl/admin/approve_user.php';
}
