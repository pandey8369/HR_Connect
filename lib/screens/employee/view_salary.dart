import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/firestore_service.dart';
import '../../utils/export_utils.dart';

class ViewSalary extends StatefulWidget {
  const ViewSalary({Key? key}) : super(key: key);

  @override
  _ViewSalaryState createState() => _ViewSalaryState();
}

class _ViewSalaryState extends State<ViewSalary> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _salarySlipsFuture;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _salarySlipsFuture = _firestoreService.fetchSalarySlips(uid);
    } else {
      _salarySlipsFuture = Future.value([]);
    }
  }

  void _openPdf(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the PDF')),
      );
    }
  }

  Future<void> _exportSalarySlip(Map<String, dynamic> slip) async {
    setState(() {
      _isExporting = true;
    });
    try {
      await ExportUtils.exportSalaryPDF(slip);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Salary Slips'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _salarySlipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading salary slips'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No salary slips found.'));
          } else {
            final slips = snapshot.data!;
            return ListView.builder(
              itemCount: slips.length,
              itemBuilder: (context, index) {
                final slip = slips[index];
                final month = slip['month'] ?? 'Unknown Month';
                final year = slip['year']?.toString() ?? '';
                final pdfUrl = slip['pdf_url'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('$month $year', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: () {
                            if (pdfUrl.isNotEmpty) {
                              _openPdf(pdfUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF not available')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download),
                          tooltip: 'Export as PDF',
                          onPressed: _isExporting ? null : () => _exportSalarySlip(slip),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
