class ClassroomModel {
  final int classId;
  final String subjectName;
  final String? joinKey; // นิสิตอาจไม่เห็น Key หรือเห็นก็ได้แล้วแต่ดีไซน์
  final String teacherName; // ชื่ออาจารย์ (ถ้ามี join table)

  ClassroomModel({
    required this.classId,
    required this.subjectName,
    this.joinKey,
    this.teacherName = '',
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      classId: int.parse(json['class_id'].toString()),
      subjectName: json['subject_name'] ?? 'Unknown Subject',
      joinKey: json['join_key'],
      // บาง API อาจส่งชื่ออาจารย์มา หรือไม่ส่งมาก็ได้ เช็ค null ก่อน
      teacherName: json['teacher_name'] ?? '', 
    );
  }
}