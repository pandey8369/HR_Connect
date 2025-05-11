import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/firestore_service.dart';

class ViewMyAttendance extends StatefulWidget {
  const ViewMyAttendance({Key? key}) : super(key: key);

  @override
  _ViewMyAttendanceState createState() => _ViewMyAttendanceState();
}

class _ViewMyAttendanceState extends State<ViewMyAttendance> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _attendanceFuture;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userName;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _attendanceFuture = _firestoreService.fetchAttendanceRecords(user.uid);
      _loadUserName(user.uid);
    } else {
      _attendanceFuture = Future.value([]);
    }
  }

  Future<void> _loadUserName(String uid) async {
    try {
      final userData = await _firestoreService.getUserById(uid);
      setState(() {
        _userName = userData?.name ?? 'User (restricted)';
      });
    } catch (e) {
      setState(() {
        _userName = 'User (restricted)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading attendance records'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          } else {
            final records = snapshot.data!;
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final date = record['date'] ?? 'Unknown Date';
                final status = record['status'] ?? 'Unknown Status';
                final checkIn = record['checkIn'] ?? '-';
                final checkOut = record['checkOut'] ?? '-';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(_userName ?? 'User (restricted)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date),
                        Text('Status: $status'),
                        Text('Check In: $checkIn'),
                        Text('Check Out: $checkOut'),
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
