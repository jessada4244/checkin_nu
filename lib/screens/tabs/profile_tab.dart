import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/images/profile_placeholder.png',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'ชื่อผู้ใช้',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print('Logged out');
              },
              child: Text('ออกจากระบบ',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
