import 'package:flutter/material.dart';
import '../class_detail_screen.dart';
import '../../widgets/create_class_modal.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final classes = [
      {'code': 'CS101', 'name': 'Intro to CS', 'student': 40, 'color': 0xFF74B9FF},
      {'code': 'IT202', 'name': 'Database Systems', 'student': 35, 'color': 0xFFA29BFE},
      {'code': 'SE301', 'name': 'Software Eng.', 'student': 50, 'color': 0xFF55EFC4},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ห้องเรียนของฉัน'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
        ),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final cls = classes[index];
          return _buildClassCard(context, cls);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            builder: (context) => const CreateClassModal(),
          );
        },
        backgroundColor: const Color(0xFF0984E3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("สร้างห้องเรียน", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> cls) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ClassDetailScreen(
                classCode: cls['code'].toString(),
                className: cls['name'].toString(),
              ),
            ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(cls['color'] as int).withOpacity(0.2),
                child: Icon(Icons.school, color: Color(cls['color'] as int), size: 30),
              ),
              const SizedBox(height: 15),
              Text(cls['code'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(cls['name'].toString(), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: Text("${cls['student']} คน", style: const TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
      ),
    );
  }
}