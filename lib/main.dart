import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';




class LecturerLiveCheckInPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const LecturerLiveCheckInPage({super.key, required this.courseId, required this.courseName});

  @override
  _LecturerLiveCheckInPageState createState() => _LecturerLiveCheckInPageState();
}

class _LecturerLiveCheckInPageState extends State<LecturerLiveCheckInPage> {
  String _qrData = "init-data"; // ข้อมูลที่จะถูกเปลี่ยนเรื่อยๆ เพื่อกันการแคปหน้าจอ
  Timer? _timer;
  bool _isSessionActive = false;
  final int _studentCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ฟังก์ชันจำลองการเปลี่ยน QR Code ทุก 5 วินาที (Anti-Cheat logic)
  void _startSession() {
    setState(() {
      _isSessionActive = true;
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        // ในการใช้งานจริง ต้อง Gen Token จาก Server ส่งไป
        _qrData = "${widget.courseId}-${DateTime.now().millisecondsSinceEpoch}";
      });
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check-in: ${widget.courseName}"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // 1. ส่วนตั้งค่า (Top Control)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("กำหนดเวลาสาย (นาที)", style: TextStyle(fontSize: 12)),
                    SizedBox(width: 100, child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "15"))),
                  ],
                ),
                Switch(
                  value: _isSessionActive,
                  onChanged: (val) {
                    val ? _startSession() : _stopSession();
                  },
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
          ),

          // 2. พื้นที่แสดง QR (Center)
          Expanded(
            child: Center(
              child: _isSessionActive
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Scan to Check-in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        // ใช้ Library qr_flutter
                        QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 280.0,
                        ),
                        SizedBox(height: 10),
                        LinearProgressIndicator(), // Animation ให้รู้ว่ากำลัง refresh
                        SizedBox(height: 20),
                        Text("Code: 123 456", style: TextStyle(fontSize: 24, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 100, color: Colors.grey),
                        Text("ปิดรับการเช็คชื่อ", style: TextStyle(color: Colors.grey, fontSize: 18)),
                      ],
                    ),
            ),
          ),

          // 3. สรุปผล Real-time (Bottom)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("เข้าเรียนแล้ว", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                Text("$_studentCount / 40", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}