import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../service/firestore_service.dart';

class ViewNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

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
          return ListView.separated(
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
          );
        },
      ),
    );
  }
}
