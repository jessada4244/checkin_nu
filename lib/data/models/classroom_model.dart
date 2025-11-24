class ClassroomModel {
  final String id;
  final String name;

  ClassroomModel({required this.id, required this.name});

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(id: json['id']?.toString() ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
