import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // แผนที่ฟรี OSM
import 'package:latlong2/latlong.dart';       // จัดการพิกัด
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/utils/locations_tools.dart';

class PickLocationScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const PickLocationScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  late LatLng _pickedLocation;
  final MapController _mapController = MapController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ถ้ามีพิกัดเดิม ให้เริ่มที่นั่น ถ้าไม่มี ให้เริ่มที่ กรุงเทพฯ
    if (widget.initialLat != null && widget.initialLng != null) {
      _pickedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      _isLoading = false;
    } else {
      _pickedLocation = const LatLng(13.7563, 100.5018); 
      _getCurrentLocation(); // เปิดมาลองหาตำแหน่งเลย
    }
  }

  // ฟังก์ชัน: กดปุ่ม GPS แล้ววิ่งไปหาตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true); // หมุนติ้วๆ
    try {
      Position? position = await LocationUtil.getCurrentLocation();
      if (position != null) {
        if (mounted) {
          setState(() {
            _pickedLocation = LatLng(position.latitude, position.longitude);
            _isLoading = false;
          });
          // สั่งแมพให้เลื่อนไปหาเรา
          _mapController.move(_pickedLocation, 17.0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('หาพิกัดไม่ได้: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกตำแหน่งห้องเรียน')),
      body: Stack(
        children: [
          // 1. ตัวแผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 16.0,
              // เมื่อเลื่อนแผนที่ ให้หมุดแดงเปลี่ยนค่าตามเป้ากลางจอ
              onPositionChanged: (camera, hasGesture) {
                _pickedLocation = camera.center; 
              },
            ),
            children: [
              TileLayer(
                // ลิงก์โหลดรูปแผนที่ (ต้องมีเน็ตถึงจะขึ้น)
                
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.checkin',
              ),
            ],
          ),

          // 2. หมุดแดง (อยู่ตรงกลางจอเสมอ)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), // ยกหัวหมุดขึ้นเพื่อให้ปลายจิ้มตรงกลาง
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),

          // 3. Loading (แสดงตอนกำลังหา GPS)
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      // 4. ปุ่มกดต่างๆ ด้านล่าง
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ปุ่ม GPS
          FloatingActionButton(
            heroTag: "btn_gps",
            backgroundColor: Colors.white,
            onPressed: _getCurrentLocation, // กดแล้วเรียกฟังก์ชันหาพิกัด
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          
          // ปุ่มยืนยัน
          SizedBox(
            width: 160,
            child: FloatingActionButton.extended(
              heroTag: "btn_confirm",
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
              label: const Text('ยืนยันตำแหน่ง', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.check, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}