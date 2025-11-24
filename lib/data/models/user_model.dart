class UserModel {
  final int userId;
  final String? studentId; // อาจเป็น null ถ้าเป็น Admin
  final String firstName;
  final String lastName;
  final String role; // 'admin', 'teacher', 'student'
  final String? phone;
  final String? deviceId;

  UserModel({
    required this.userId,
    this.studentId,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.deviceId,
  });

  // แปลง JSON จาก PHP ให้เป็น Object ใน Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: int.parse(json['user_id'].toString()), // แปลงเป็น int เสมอเพื่อความชัวร์
      studentId: json['student_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'student',
      phone: json['phone'],
      deviceId: json['device_id'],
    );
  }

  // แปลง Object กลับเป็น JSON (เผื่อใช้ตอนบันทึกใส่เครื่อง)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone': phone,
      'device_id': deviceId,
    };
  }
}