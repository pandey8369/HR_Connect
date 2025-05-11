import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/firestore_service.dart';

class ViewEvents extends StatefulWidget {
  const ViewEvents({Key? key}) : super(key: key);

  @override
  _ViewEventsState createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _firestoreService.fetchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading events'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No upcoming events.'));
        } else {
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final title = event['title'] ?? 'Untitled Event';
              final timestamp = event['date'];
              String formattedDate = 'Unknown Date';
              if (timestamp != null) {
                try {
                  final date = DateTime.parse(timestamp.toDate().toString());
                  formattedDate = DateFormat.yMMMMd().format(date);
                } catch (_) {}
              }
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formattedDate),
                ),
              );
            },
          );
        }
      },
    );
  }
}
