import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/firestore_service.dart';

class ViewSalary extends StatefulWidget {
  const ViewSalary({Key? key}) : super(key: key);

  @override
  _ViewSalaryState createState() => _ViewSalaryState();
}

class _ViewSalaryState extends State<ViewSalary> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _salarySlipsFuture;

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
        SnackBar(content: Text('Could not open the PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _salarySlipsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading salary slips'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No salary slips found.'));
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
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('$month $year', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        _openPdf(pdfUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF not available')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
