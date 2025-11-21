import 'package:flutter/material.dart';

class CreateClassModal extends StatefulWidget {
  const CreateClassModal({super.key});

  @override
  State<CreateClassModal> createState() => _CreateClassModalState();
}

class _CreateClassModalState extends State<CreateClassModal> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("สร้างห้องเรียนใหม่", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: "รหัสวิชา", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.qr_code)),
            ),
            const SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(labelText: "ชื่อวิชา", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.book)),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0984E3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("สร้างห้องเรียน"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}