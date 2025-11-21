import 'package:flutter/material.dart';
import 'live_checkin_screen.dart';

class ClassDetailScreen extends StatelessWidget {
  final String className;
  final String classCode;

  const ClassDetailScreen({super.key, required this.className, required this.classCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(classCode)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(className, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            InkWell(
              onTap: () => _showSetupCheckInDialog(context),
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text("เริ่มการเช็คชื่อ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("สร้าง QR Code สำหรับคาบนี้", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _menuButton(Icons.people, "รายชื่อนิสิต", Colors.orange, () {})),
                const SizedBox(width: 15),
                Expanded(child: _menuButton(Icons.history, "ประวัติย้อนหลัง", Colors.purple, () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showSetupCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ตั้งค่าการเช็คชื่อ"),
        content: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "15", suffixText: "นาที", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0984E3), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveCheckInScreen()));
            },
            child: const Text("สร้าง QR Code"),
          )
        ],
      ),
    );
  }
}