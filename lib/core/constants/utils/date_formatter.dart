import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(String? dateString) {
    if (dateString == null) return '-';
    try {
      DateTime date = DateTime.parse(dateString);
      // เพิ่มปี 543 เพื่อเป็น พ.ศ.
      // หมายเหตุ: ต้อง setup locale 'th' ใน main.dart ด้วย หรือใช้ logic บวกปีเอาเองแบบง่ายๆ
      return '${DateFormat('dd/MM/').format(date)}${date.year + 543} ${DateFormat('HH:mm').format(date)} น.';
    } catch (e) {
      return dateString;
    }
  }
}



// import 'package:intl/intl.dart';

// class DateFormatter {
//   static String formatDateTime(String? dateString) {
//     if (dateString == null) return '-';
//     try {
//       DateTime date = DateTime.parse(dateString);
//       // เพิ่มปี 543 เพื่อเป็น พ.ศ.
//       var formatter = DateFormat('d MMM yyyy HH:mm', 'th'); 
//       // หมายเหตุ: ต้อง setup locale 'th' ใน main.dart ด้วย หรือใช้ logic บวกปีเอาเองแบบง่ายๆ
//       return '${DateFormat('dd/MM/').format(date)}${date.year + 543} ${DateFormat('HH:mm').format(date)} น.';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }