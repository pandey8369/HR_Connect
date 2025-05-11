import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadSalary extends StatefulWidget {
  @override
  _UploadSalaryState createState() => _UploadSalaryState();
}

class _UploadSalaryState extends State<UploadSalary> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadMessage;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _uploadMessage = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _uploadMessage = 'User not logged in';
          _isUploading = false;
        });
        return;
      }

      final fileName = _selectedFile!.path.split('/').last;
      final storageRef = _storage.ref().child('salary_slips/${user.uid}/$fileName');

      final uploadTask = storageRef.putFile(_selectedFile!);
      final snapshot = await uploadTask.whenComplete(() {});

      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Extract month and year from file name or use current date
      String monthYear = fileName.replaceAll('.pdf', '');

      // Save URL in Firestore under salary_slips/uid document
      final docRef = _firestore.collection('salary_slips').doc(user.uid);
      await docRef.set({
        monthYear: downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        _uploadMessage = 'Upload successful for $monthYear';
        _selectedFile = null;
      });
    } catch (e) {
      setState(() {
        _uploadMessage = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Salary Slip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file),
              label: Text('Select PDF File'),
            ),
            SizedBox(height: 16),
            if (_selectedFile != null)
              Text('Selected file: ${_selectedFile!.path.split('/').last}'),
            SizedBox(height: 16),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _selectedFile == null ? null : _uploadFile,
                    child: Text('Upload'),
                  ),
            if (_uploadMessage != null) ...[
              SizedBox(height: 16),
              Text(
                _uploadMessage!,
                style: TextStyle(
                  color: _uploadMessage!.startsWith('Upload successful')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
