// ไฟล์ lib/data/models/classroom_model.dart
class ClassroomModel {
  final int classId;
  final String subjectName;
  final String? joinKey;
  final int capacity;
  final String? defaultLateTime; // "08:30"
  final double? lat;
  final double? lng;

  ClassroomModel({
    required this.classId,
    required this.subjectName,
    this.joinKey,
    this.capacity = 0,
    this.defaultLateTime,
    this.lat,
    this.lng,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      classId: int.parse(json['class_id'].toString()),
      subjectName: json['subject_name'] ?? '',
      joinKey: json['join_key'],
      capacity: int.parse((json['capacity'] ?? 0).toString()),
      defaultLateTime: json['default_late_time'],
      lat: json['class_lat'] != null ? double.parse(json['class_lat'].toString()) : null,
      lng: json['class_lng'] != null ? double.parse(json['class_lng'].toString()) : null,
    );
  }
}