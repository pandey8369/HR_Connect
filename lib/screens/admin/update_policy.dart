import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdatePolicy extends StatefulWidget {
  @override
  _UpdatePolicyState createState() => _UpdatePolicyState();
}

class _UpdatePolicyState extends State<UpdatePolicy> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  bool _isLoading = false;

  Future<void> _addPolicy() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('policies').add({
        'title': _title,
        'content': _content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Policy added successfully')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add policy: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<QuerySnapshot> _getPoliciesStream() {
    return _firestore.collection('policies').orderBy('updatedAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Policies'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPoliciesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading policies'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final policies = snapshot.data!.docs;
                if (policies.isEmpty) {
                  return Center(child: Text('No policies found'));
                }
                return ListView.builder(
                  itemCount: policies.length,
                  itemBuilder: (context, index) {
                    final policy = policies[index];
                    return ListTile(
                      title: Text(policy['title'] ?? ''),
                      subtitle: Text(policy['content'] ?? ''),
                      trailing: Text(
                        policy['updatedAt'] != null
                            ? (policy['updatedAt'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                            : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Policy Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    onSaved: (value) => _title = value!.trim(),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Policy Content'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter content' : null,
                    onSaved: (value) => _content = value!.trim(),
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _addPolicy,
                          child: Text('Add / Update Policy'),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
