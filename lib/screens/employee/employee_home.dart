import 'package:flutter/material.dart';
import 'view_policies.dart';
import 'view_salary.dart';
import 'view_events.dart';
import 'view_my_attendance.dart';
import 'mark_attendance.dart';
import '../../models/user_model.dart';

class EmployeeHome extends StatefulWidget {
  final AppUser? user;

  const EmployeeHome({Key? key, this.user}) : super(key: key);

  @override
  _EmployeeHomeState createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      ViewPolicies(),
      ViewSalary(),
      ViewEvents(),
      ViewMyAttendance(),
      MarkAttendance(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildUserInfoCard() {
    final userName = widget.user?.name ?? 'User (restricted)';
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.person, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.pushNamed(context, '/view_notifications', arguments: widget.user);
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Profile Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/profile_settings', arguments: widget.user);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfoCard(),
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Salary Slips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: 'Mark Attendance',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
