import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb

class DeviceInfoUtil {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  // ฟังก์ชันดึง Device ID แบบ Asynchronous
  static Future<String> getDeviceId() async {
    String deviceId = '';

    try {
      if (kIsWeb) {
        // กรณี Web (Browser ไม่ยอมให้ Device ID ตรงๆ ต้องใช้ UserAgent แทน ซึ่งไม่ปลอดภัย 100% แต่ดีกว่าไม่มี)
        var webInfo = await _deviceInfoPlugin.webBrowserInfo;
        deviceId = webInfo.userAgent ?? 'unknown_web_device';
      } else if (Platform.isAndroid) {
        // กรณี Android
        var androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id; // Unique ID ของ Android
      } else if (Platform.isIOS) {
        // กรณี iOS
        var iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
    } catch (e) {
      print('Error getting device ID: $e');
      deviceId = 'error_device_id';
    }

    return deviceId;
  }
}