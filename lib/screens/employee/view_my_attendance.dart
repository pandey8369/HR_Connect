import 'package:flutter/material.dart';
import '../../service/firestore_service.dart';

class ViewMyAttendance extends StatefulWidget {
  const ViewMyAttendance({Key? key}) : super(key: key);

  @override
  _ViewMyAttendanceState createState() => _ViewMyAttendanceState();
}

class _ViewMyAttendanceState extends State<ViewMyAttendance> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _attendanceFuture;

  // TODO: Replace with actual user UID retrieval logic
  final String _userUid = 'current_user_uid';

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _firestoreService.fetchAttendanceRecords(_userUid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _attendanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading attendance records'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No attendance records found.'));
        } else {
          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final date = record['date'] ?? 'Unknown Date';
              final status = record['status'] ?? 'Unknown Status';
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(date),
                  subtitle: Text('Status: \$status'),
                ),
              );
            },
          );
        }
      },
    );
  }
}
