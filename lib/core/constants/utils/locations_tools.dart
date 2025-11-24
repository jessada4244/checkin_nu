import 'package:geolocator/geolocator.dart';

class LocationUtil {
  // ขอสิทธิ์และดึงพิกัดปัจจุบัน
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. เช็คว่าเปิด GPS หรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // แจ้งเตือนให้เปิด GPS
      return Future.error('กรุณาเปิด GPS เพื่อทำการเช็คชื่อ');
    }

    // 2. เช็คสิทธิ์การเข้าถึง (Permission)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('คุณปฏิเสธการเข้าถึงตำแหน่ง');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('สิทธิ์ระบุตำแหน่งถูกปิดถาวร กรุณาเปิดในการตั้งค่า');
    }

    // 3. ดึงพิกัด
    return await Geolocator.getCurrentPosition();
  }
}