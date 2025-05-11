import 'package:flutter/material.dart';
import '../../service/firestore_service.dart';

class ViewPolicies extends StatefulWidget {
  const ViewPolicies({Key? key}) : super(key: key);

  @override
  _ViewPoliciesState createState() => _ViewPoliciesState();
}

class _ViewPoliciesState extends State<ViewPolicies> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _policiesFuture;

  @override
  void initState() {
    super.initState();
    _policiesFuture = _firestoreService.fetchCompanyPolicies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _policiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading policies'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No company policies found.'));
        } else {
          final policies = snapshot.data!;
          return ListView.builder(
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              final title = policy['title'] ?? 'Untitled Policy';
              final description = policy['description'] ?? '';
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(description),
                  isThreeLine: description.length > 50,
                ),
              );
            },
          );
        }
      },
    );
  }
}
