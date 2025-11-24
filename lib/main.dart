import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ใช้ฟอนต์สวยๆ
import 'package:intl/date_symbol_data_local.dart'; // สำหรับวันที่ภาษาไทย

// Import Core & Services
import 'core/constants/app_colors.dart';
import 'data/services/auth_service.dart';
import 'data/models/user_model.dart';

// Import หน้าจอทั้งหมด (Modules)
import 'modules/auth/login_screen.dart';
import 'modules/auth/register_screen.dart';
import 'modules/student/student_dashboard.dart';
import 'modules/teacher/teacher_dashboard.dart';
import 'modules/admin/admin_dashboard.dart';

void main() async {
  // ต้องมีบรรทัดนี้เมื่อ main เป็น async เพื่อให้ initialize plugins ได้
  WidgetsFlutterBinding.ensureInitialized();
  
  // ตั้งค่า locale สำหรับวันที่ภาษาไทย (ใช้ใน DateFormatter)
  await initializeDateFormatting('th_TH', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-in Classroom',
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug มุมขวาบน

      // --- ตั้งค่า Theme ของแอป ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        // ใช้ Google Fonts 'Sarabun' ทั้งแอป เพื่อให้อ่านภาษาไทยง่าย
        textTheme: GoogleFonts.sarabunTextTheme(),
        
        // ตั้งค่า AppBar กลาง
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // --- ตั้งค่า Routes (เส้นทาง) ---
      // กำหนดให้เริ่มต้นที่หน้า SessionCheck เพื่อตรวจสอบสถานะล็อกอิน
      initialRoute: '/',
      routes: {
        '/': (context) => const SessionCheck(), // หน้าโหลดเพื่อเช็ค Session
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/teacher_dashboard': (context) => const TeacherDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

// --- Widget สำหรับเช็ค Session (Auto Login) ---
class SessionCheck extends StatefulWidget {
  const SessionCheck({super.key});

  @override
  State<SessionCheck> createState() => _SessionCheckState();
}

class _SessionCheckState extends State<SessionCheck> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // ฟังก์ชันตรวจสอบว่าเคยล็อกอินค้างไว้ไหม
  void _checkUser() async {
    // หน่วงเวลานิดหน่อยเพื่อให้เห็น Logo หรือ Splash Screen (Optional)
    await Future.delayed(const Duration(seconds: 1)); 

    final authService = AuthService();
    UserModel? user = await authService.getUserSession();

    if (mounted) {
      if (user != null) {
        // ถ้ามี User ค้างอยู่ ให้เด้งไปตาม Role ของคนนั้น
        _navigateToDashboard(user.role);
      } else {
        // ถ้าไม่มี หรือล็อกอินหลุด ให้ไปหน้า Login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _navigateToDashboard(String role) {
    String routeName = '/login';

    switch (role) {
      case 'admin':
        routeName = '/admin_dashboard';
        break;
      case 'teacher':
        routeName = '/teacher_dashboard';
        break;
      case 'student':
        routeName = '/student_dashboard';
        break;
      default:
        routeName = '/login';
    }

    // pushReplacementNamed คือการแทนที่หน้าปัจจุบัน (กด Back ไม่ได้)
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    // หน้าจอระหว่างรอโหลด (Splash Screen)
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10),
            Text(
              'กำลังตรวจสอบข้อมูล...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}