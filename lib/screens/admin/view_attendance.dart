import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/firestore_service.dart';
import '../employee/view_my_attendance.dart';

class ViewAttendance extends StatefulWidget {
  @override
  _ViewAttendanceState createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, Map<String, dynamic>> _attendanceData = {}; // uid -> attendance record
  Map<String, String> _userNames = {}; // uid -> user name

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final attendance = await _firestoreService.fetchAllAttendanceByDate(dateStr);

      // Fetch user names for the uids
      Map<String, String> userNames = {};
      for (var uid in attendance.keys) {
        try {
          final user = await _firestoreService.getUserById(uid);
          userNames[uid] = user?.name ?? 'Unknown User';
        } catch (e) {
          debugPrint('Error fetching user data for uid $uid: $e');
          if (e.toString().contains('permission-denied')) {
            userNames[uid] = 'User (restricted)';
          } else {
            userNames[uid] = 'Unknown User';
          }
        }
      }

      setState(() {
        _attendanceData = attendance;
        _userNames = userNames;
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

  Future<void> _saveAttendance() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      for (var uid in _attendanceData.keys) {
        await _firestoreService.updateAttendanceEntry(uid, dateStr, _attendanceData[uid]!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attendance: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _updateAttendanceStatus(String uid, String status) {
    setState(() {
      final current = _attendanceData[uid] ?? {};
      _attendanceData[uid] = {
        ...current,
        'status': status,
        'checkIn': status == 'Absent' ? null : current['checkIn'],
        'checkOut': status == 'Absent' ? null : current['checkOut'],
      };
    });
  }

  void _updateCheckInTime(String uid, String time) {
    setState(() {
      final current = _attendanceData[uid] ?? {};
      _attendanceData[uid] = {
        ...current,
        'checkIn': time,
        'status': 'Present',
      };
    });
  }

  void _updateCheckOutTime(String uid, String time) {
    setState(() {
      final current = _attendanceData[uid] ?? {};
      _attendanceData[uid] = {
        ...current,
        'checkOut': time,
        'status': 'Present',
      };
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadAttendance();
    }
  }

  Future<void> _pickTime(BuildContext context, String uid, bool isCheckIn) async {
    final initialTime = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final formattedTime = picked.format(context);
      if (isCheckIn) {
        _updateCheckInTime(uid, formattedTime);
      } else {
        _updateCheckOutTime(uid, formattedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: View Attendance'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveAttendance,
            tooltip: 'Save Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceData.isEmpty
              ? const Center(child: Text('No attendance data found for selected date'))
              : ListView.builder(
                  itemCount: _attendanceData.length,
                  itemBuilder: (context, index) {
                    final uid = _attendanceData.keys.elementAt(index);
                    final record = _attendanceData[uid]!;
                    final userName = _userNames[uid] ?? 'Unknown User';
                    final status = record['status'] ?? 'Absent';
                    final checkIn = record['checkIn'] ?? '-';
                    final checkOut = record['checkOut'] ?? '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Status: ', style: TextStyle(fontSize: 16)),
                                DropdownButton<String>(
                                  value: status,
                                  items: const [
                                    DropdownMenuItem(value: 'Present', child: Text('Present')),
                                    DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateAttendanceStatus(uid, val);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Check In: ', style: TextStyle(fontSize: 16)),
                                TextButton(
                                  onPressed: status == 'Present'
                                      ? () => _pickTime(context, uid, true)
                                      : null,
                                  child: Text(checkIn, style: const TextStyle(fontSize: 16)),
                                ),
                                const SizedBox(width: 24),
                                const Text('Check Out: ', style: TextStyle(fontSize: 16)),
                                TextButton(
                                  onPressed: status == 'Present'
                                      ? () => _pickTime(context, uid, false)
                                      : null,
                                  child: Text(checkOut, style: const TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
