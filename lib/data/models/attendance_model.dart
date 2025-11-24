class AttendanceModel {
  final String studentName; // สำหรับอาจารย์ดู
  final String studentId;
  final String status; // 'present', 'late'
  final DateTime scanTime;
  final String subjectName; // สำหรับนิสิตดูประวัติรวม

  AttendanceModel({
    required this.studentName,
    required this.studentId,
    required this.status,
    required this.scanTime,
    required this.subjectName,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentName: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      studentId: json['student_id'] ?? '',
      status: json['status'] ?? 'unknown',
      // แปลง String จาก SQL (YYYY-MM-DD HH:MM:SS) เป็น DateTime ของ Dart
      scanTime: json['scan_time'] != null 
          ? DateTime.parse(json['scan_time']) 
          : DateTime.now(),
      subjectName: json['subject_name'] ?? '',
    );
  }
}