import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // import package กล้อง
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/student_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  // ฟังก์ชันเมื่อสแกนเจอ
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // ป้องกันการยิงซ้ำรัวๆ
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        cameraController.stop(); // หยุดกล้องชั่วคราว

        try {
          // 1. แปลงข้อมูลจาก QR Code
          final data = jsonDecode(barcode.rawValue!);
          
          if (data['type'] == 'checkin' && data['session_id'] != null) {
            int sessionId = int.parse(data['session_id'].toString());
            
            // 2. ดึงข้อมูล User ปัจจุบัน
            final user = await AuthService().getUserSession();
            
            if (user != null) {
              // 3. เรียก API เช็คชื่อ (Anti-Cheat Logic อยู่ในนี้)
              final message = await StudentService().checkAttendance(sessionId, user.userId);
              
              if (mounted) _showResultDialog('สำเร็จ', message, true);
            }
          } else {
            if (mounted) _showResultDialog('ผิดพลาด', 'QR Code ไม่ถูกต้อง', false);
          }
        } catch (e) {
          // แจ้งเตือนกรณี Error หรือ โกง
          if (mounted) _showResultDialog('เกิดข้อผิดพลาด', e.toString().replaceAll('Exception: ', ''), false);
        }
      }
    }
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: isSuccess ? AppColors.success : AppColors.error)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 60,
              color: isSuccess ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด Dialog
              Navigator.pop(context); // ปิดหน้า Scan กลับไป Dashboard
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สแกน QR เพื่อเช็คชื่อ')),
      body: Stack(
        children: [
          // พื้นที่กล้อง
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // กรอบสี่เหลี่ยม (Overlay) เพื่อบอกตำแหน่งเล็ง
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          
          // Text คำแนะนำ
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 40),
              color: Colors.black54,
              child: const Text(
                'เล็ง QR Code ให้อยู่ในกรอบ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Loading Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}

// Custom Shape สำหรับทำกรอบสแกน
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero)
      ..addRect(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize;
    final _borderLength = borderLength;
    final _borderRadius = borderRadius;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: _cutOutSize,
      height: _cutOutSize,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRect(cutOutRect, Paint()..blendMode = BlendMode.clear)
      ..restore();

    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top + _borderRadius)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.top, cutOutRect.left + _borderRadius, cutOutRect.top)
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.top)
      
      ..moveTo(cutOutRect.right, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.top + _borderRadius)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.top, cutOutRect.right - _borderRadius, cutOutRect.top)
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.top)

      ..moveTo(cutOutRect.right, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - _borderRadius)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.bottom, cutOutRect.right - _borderRadius, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom)

      ..moveTo(cutOutRect.left, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - _borderRadius)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.bottom, cutOutRect.left + _borderRadius, cutOutRect.bottom)
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.bottom);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}