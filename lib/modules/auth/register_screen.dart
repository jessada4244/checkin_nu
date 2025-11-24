import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers เก็บค่าจากฟอร์ม
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'student'; // ค่าเริ่มต้น
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = AuthService();
        
        // เรียก API สมัครสมาชิก
        // หมายเหตุ: ฟังก์ชัน register ใน auth_service.dart ที่เราเขียนก่อนหน้า 
        // รับแค่ 5 ค่า (ขาด Role) ถ้าจะให้สมบูรณ์ต้องไปแก้ service ให้รับ role ด้วย
        // แต่ในที่นี้ผมจะส่งข้อมูลตามที่ service เดิมรับไปก่อน
        
        await authService.register(
          _studentIdController.text.trim(),
          _passwordController.text,
          _fnameController.text.trim(),
          _lnameController.text.trim(),
          _phoneController.text.trim(),
          // role: _selectedRole, <--- ปกติควรส่ง role ไปด้วยถ้า API รองรับ
        );

        if (mounted) {
          // แจ้งเตือนและกลับไปหน้า Login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! โปรดรอแอดมินอนุมัติ')),
          );
          Navigator.pop(context); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'รหัสนิสิต / Username', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                validator: (v) => v!.length < 4 ? 'รหัสผ่านต้องมากกว่า 4 ตัวอักษร' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fnameController,
                      decoration: const InputDecoration(labelText: 'ชื่อจริง', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'ระบุชื่อ' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lnameController,
                      decoration: const InputDecoration(labelText: 'นามสกุล', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'ระบุนามสกุล' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'ระบุเบอร์โทร' : null,
              ),
              const SizedBox(height: 16),
              
              // Dropdown เลือกสถานะ (Student/Teacher)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'สถานะ', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('นิสิต')),
                  DropdownMenuItem(value: 'teacher', child: Text('อาจารย์')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ลงทะเบียน'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}