import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/firestore_service.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({Key? key}) : super(key: key);

  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isMarking = false;

  String? _statusToday;
  String? _checkInTime;
  String? _checkOutTime;

  String get _todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      final records = await _firestoreService.fetchAttendanceRecords(user.uid);
      final todayRecord = records.firstWhere(
        (record) => record['date'] == _todayDate,
        orElse: () => {},
      );
      setState(() {
        _statusToday = todayRecord['status'];
        _checkInTime = todayRecord['checkIn'];
        _checkOutTime = todayRecord['checkOut'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markCheckIn() async {
    setState(() {
      _isMarking = true;
    });
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      final now = DateFormat('HH:mm').format(DateTime.now());
      await _firestoreService.markCheckIn(user.uid, _todayDate, now);
      await _loadTodayAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check in: $e')),
      );
    } finally {
      setState(() {
        _isMarking = false;
      });
    }
  }

  Future<void> _markCheckOut() async {
    setState(() {
      _isMarking = true;
    });
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      final now = DateFormat('HH:mm').format(DateTime.now());
      await _firestoreService.markCheckOut(user.uid, _todayDate, now);
      await _loadTodayAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check out: $e')),
      );
    } finally {
      setState(() {
        _isMarking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canCheckIn = _statusToday != 'Present' || _checkInTime == null;
    final bool canCheckOut = _statusToday == 'Present' && _checkInTime != null && _checkOutTime == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Today: $_todayDate',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 30),
                  if (_statusToday == 'Present')
                    Column(
                      children: [
                        Text('Check In: ${_checkInTime ?? '-'}', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Check Out: ${_checkOutTime ?? '-'}', style: TextStyle(fontSize: 18)),
                      ],
                    )
                  else
                    const Text('No attendance marked for today', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: canCheckIn && !_isMarking ? _markCheckIn : null,
                    child: _isMarking && canCheckIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: canCheckOut && !_isMarking ? _markCheckOut : null,
                    child: _isMarking && canCheckOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_my_attendance');
                    },
                    child: const Text('View Past Attendance'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
