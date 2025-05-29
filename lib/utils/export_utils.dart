import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xfile/xfile.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ExportUtils {
  static Future<String> exportAttendanceCSV(Map<String, dynamic> attendanceData) async {
    List<List<String>> rows = [
      ['Date', 'Employee ID', 'Status', 'CheckIn', 'CheckOut']
    ];

    attendanceData.forEach((date, records) {
      for (var record in records) {
        rows.add([
          date,
          record['employeeId'] ?? '-',
          record['status'] ?? '-',
          record['checkIn'] ?? '-',
          record['checkOut'] ?? '-',
        ]);
      }
    });

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "\${directory.path}/attendance_\${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    return path;
  }

  static Future<void> shareFile(String filePath) async {
    final xfile = XFile(filePath);
    await Share.shareXFiles([xfile]);
  }

  static Future<void> exportSalaryPDF(Map<String, dynamic> salaryData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Salary Slip", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text("Name: \${salaryData['name']}"),
            pw.Text("Month: \${salaryData['month']}"),
            pw.Text("Basic: ₹\${salaryData['basic']}"),
            pw.Text("Bonus: ₹\${salaryData['bonus']}"),
            pw.Text("Total: ₹\${salaryData['total']}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static Future<void> exportEventsPDF(List<Map<String, dynamic>> events) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Company Events", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...events.map((event) {
              final title = event['title'] ?? 'Untitled Event';
              String formattedDate = 'Unknown Date';
              final timestamp = event['date'];
              if (timestamp != null) {
                try {
                  final date = DateTime.parse(timestamp.toDate().toString());
                  formattedDate = DateFormat.yMMMMd().format(date);
                } catch (_) {}
              }
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(formattedDate),
                  pw.SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // New function to export attendance as PDF
  static Future<void> exportAttendancePDF(Map<String, dynamic> attendanceData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          List<pw.Widget> rows = [
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Employee ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('CheckIn', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('CheckOut', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.SizedBox(height: 10),
          ];

          attendanceData.forEach((date, records) {
            for (var record in records) {
              rows.add(
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(date)),
                    pw.Expanded(child: pw.Text(record['employeeId'] ?? '-')),
                    pw.Expanded(child: pw.Text(record['status'] ?? '-')),
                    pw.Expanded(child: pw.Text(record['checkIn'] ?? '-')),
                    pw.Expanded(child: pw.Text(record['checkOut'] ?? '-')),
                  ],
                ),
              );
            }
          });

          return pw.Column(children: rows);
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // New function to export notifications as CSV
  static Future<String> exportNotificationsCSV(List<Map<String, dynamic>> notifications) async {
    List<List<String>> rows = [
      ['Title', 'Message', 'To', 'Date']
    ];

    notifications.forEach((notification) {
      String dateStr = '-';
      final timestamp = notification['date'];
      if (timestamp != null) {
        try {
          final date = DateTime.parse(timestamp.toDate().toString());
          dateStr = DateFormat.yMMMMd().format(date);
        } catch (_) {}
      }
      rows.add([
        notification['title'] ?? '-',
        notification['message'] ?? '-',
        notification['to'] ?? '-',
        dateStr,
      ]);
    });

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "\${directory.path}/notifications_\${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    return path;
  }
}
