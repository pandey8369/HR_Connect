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
      if (_statusToday == 'Present' && _checkInTime != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already checked in today')),
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
      if (_statusToday != 'Present' || _checkInTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to check in first')),
        );
        return;
      }
      if (_checkOutTime != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already checked out today')),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Today: $_todayDate',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 40),
                  if (_statusToday == 'Present')
                    Column(
                      children: [
                        Text('Check In: ${_checkInTime ?? '-'}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Text('Check Out: ${_checkOutTime ?? '-'}', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    )
                  else
                    Text('No attendance marked for today', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: canCheckIn && !_isMarking ? _markCheckIn : null,
                    child: _isMarking && canCheckIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                          )
                        : const Text('Check In', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: canCheckOut && !_isMarking ? _markCheckOut : null,
                    child: _isMarking && canCheckOut
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                          )
                        : const Text('Check Out', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_my_attendance');
                    },
                    child: const Text('View Past Attendance', style: TextStyle(fontSize: 18)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
