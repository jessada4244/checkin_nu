class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role;

  UserModel({required this.id, required this.name, required this.phone, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone, 'role': role};
}
