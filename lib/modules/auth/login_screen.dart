import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ฟังก์ชันกดปุ่ม Login
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authService = AuthService();
        // เรียก API Login
        UserModel? user = await authService.login(
          _idController.text.trim(),
          _passwordController.text,
        );

        if (user != null && mounted) {
          // ถ้า Login ผ่าน ให้เช็ค Role แล้วไปหน้าถัดไป
          if (user.role == 'student') {
            // Navigator.pushReplacementNamed(context, '/student_dashboard');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยินดีต้อนรับ นิสิต')));
          } else if (user.role == 'teacher') {
            // Navigator.pushReplacementNamed(context, '/teacher_dashboard');
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยินดีต้อนรับ อาจารย์')));
          } else if (user.role == 'admin') {
            // Navigator.pushReplacementNamed(context, '/admin_dashboard');
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยินดีต้อนรับ ผู้ดูแลระบบ')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
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
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo หรือ Icon
                const Icon(Icons.school, size: 80, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Check-in Classroom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),

                // ช่องกรอก User ID / Phone
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'รหัสนิสิต / เบอร์โทรศัพท์',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกข้อมูล';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ช่องกรอก Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ปุ่ม Login
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),

                // ปุ่มสมัครสมาชิก
                TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}