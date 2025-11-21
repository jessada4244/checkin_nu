import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class LiveCheckInScreen extends StatefulWidget {
  const LiveCheckInScreen({super.key});

  @override
  State<LiveCheckInScreen> createState() => _LiveCheckInScreenState();
}

class _LiveCheckInScreenState extends State<LiveCheckInScreen> {
  String _qrData = "Start";
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _secondsElapsed++;
        _qrData = "Token-${DateTime.now().millisecondsSinceEpoch}";
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3436),
        foregroundColor: Colors.white,
        title: const Text("กำลังเช็คชื่อ..."),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black26,
            child: Center(child: Text("เวลา: ${_formatTime(_secondsElapsed)}", style: const TextStyle(color: Colors.white, fontSize: 18))),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: QrImageView(data: _qrData, version: QrVersions.auto, size: 280.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) => "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
}