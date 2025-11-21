import 'package:flutter/material.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สรุปการมาเรียน')),
      body: const Center(child: Text("หน้ารายงาน (UI ตามแบบก่อนหน้า)")),
    );
  }
}