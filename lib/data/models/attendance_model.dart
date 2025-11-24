class AttendanceModel {
  final String id;
  final String userId;
  final String classroomId;
  final DateTime timestamp;

  AttendanceModel({required this.id, required this.userId, required this.classroomId, required this.timestamp});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      classroomId: json['classroom_id']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'classroom_id': classroomId,
        'timestamp': timestamp.toIso8601String(),
      };
}
