import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hr_connect/screens/admin/update_policy.dart';
import 'package:hr_connect/screens/admin/upload_salary.dart';
import 'package:hr_connect/screens/admin/post_event.dart';
import 'package:hr_connect/screens/admin/view_attendance.dart';
class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(
              context,
              icon: Icons.policy,
              label: 'Update Policies',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdatePolicy()),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.upload_file,
              label: 'Upload Salary Slips',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UploadSalary()),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.event,
              label: 'Post Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostEvent()),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.calendar_today,
              label: 'View Attendance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ViewAttendance()),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.notifications,
              label: 'Send Notifications',
              onTap: () {
                Navigator.pushNamed(context, '/send_notification');
              },
            ),
            _buildCard(
              context,
              icon: Icons.lock_reset,
              label: 'Reset Employee Passwords',
              onTap: () {
                Navigator.pushNamed(context, '/reset_password');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
