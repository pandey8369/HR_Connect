import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostEvent extends StatefulWidget {
  @override
  _PostEventState createState() => _PostEventState();
}

class _PostEventState extends State<PostEvent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime? _date;
  String _description = '';
  bool _isLoading = false;

  Future<void> _postEvent() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a date')),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('events').add({
        'title': _title,
        'date': _date,
        'description': _description,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event posted successfully')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _date = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post event: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_date == null ? 'Select Date' : _date!.toLocal().toString().split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
                onSaved: (value) => _description = value!.trim(),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _postEvent,
                      child: Text('Post Event'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
