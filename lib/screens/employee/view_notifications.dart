import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../service/firestore_service.dart';
import '../../utils/export_utils.dart';

class ViewNotifications extends StatefulWidget {
  @override
  _ViewNotificationsState createState() => _ViewNotificationsState();
}

class _ViewNotificationsState extends State<ViewNotifications> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.fetchNotificationsForUser(''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }
          return Stack(
            children: [
              ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final title = notification['title'] ?? '';
                  final message = notification['message'] ?? '';
                  final timestamp = notification['timestamp'] as Timestamp?;
                  final dateStr = timestamp != null
                      ? timestamp.toDate().toLocal().toString()
                      : '';
                  return ListTile(
                    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(message),
                    trailing: Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _exportNotificationsCSV(notifications),
                  label: const Text('Export CSV'),
                  icon: const Icon(Icons.file_download),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportNotificationsCSV(List<Map<String, dynamic>> notifications) async {
    try {
      final filePath = await ExportUtils.exportNotificationsCSV(notifications);
      await ExportUtils.shareFile(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export notifications CSV: $e')),
      );
    }
  }
}
