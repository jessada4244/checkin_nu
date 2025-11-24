import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/utils/date_formatter.dart'; // ใช้ DateFormatter ที่มีอยู่
import '../../../data/services/teacher_service.dart';

class HistoryCheckScreen extends StatefulWidget {
  final int classId;
  final String subjectName;

  const HistoryCheckScreen({super.key, required this.classId, required this.subjectName});

  @override
  State<HistoryCheckScreen> createState() => _HistoryCheckScreenState();
}

class _HistoryCheckScreenState extends State<HistoryCheckScreen> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await TeacherService().getSessions(widget.classId);
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ประวัติ: ${widget.subjectName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text('ยังไม่มีการเช็คชื่อในวิชานี้'))
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.calendar_today, color: Colors.white),
                        ),
                        title: Text(DateFormatter.formatDateTime(session['created_at'])),
                        subtitle: Text('สถานะ: ${session['is_active'] == 1 ? "เปิดอยู่" : "ปิดแล้ว"}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // กดเพื่อดูรายชื่อคนเข้าเรียน
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionReportScreen(
                                sessionId: int.parse(session['session_id'].toString()),
                                dateLabel: DateFormatter.formatDateTime(session['created_at']),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// หน้าแสดงรายชื่อคนเข้าเรียนใน Session นั้น
class SessionReportScreen extends StatefulWidget {
  final int sessionId;
  final String dateLabel;

  const SessionReportScreen({super.key, required this.sessionId, required this.dateLabel});

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final data = await TeacherService().getAttendanceReport(widget.sessionId);
      setState(() {
        _students = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายงานการเข้าเรียน')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            width: double.infinity,
            child: Text('คาบเรียนวันที่: ${widget.dateLabel}\nจำนวนผู้เข้าเรียน: ${_students.length} คน', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('ยังไม่มีใครเช็คชื่อ'))
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          bool isLate = student['status'] == 'late';
                          return ListTile(
                            leading: Icon(
                              isLate ? Icons.warning : Icons.check_circle,
                              color: isLate ? Colors.orange : Colors.green,
                            ),
                            title: Text('${student['first_name']} ${student['last_name']}'),
                            subtitle: Text('${student['student_id']} | เวลา: ${DateFormatter.formatDateTime(student['scan_time'])}'),
                            trailing: Text(
                              isLate ? 'สาย' : 'ทันเวลา',
                              style: TextStyle(
                                color: isLate ? Colors.orange : Colors.green,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}