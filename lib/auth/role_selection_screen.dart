import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role to Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 'admin');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Color(0xFF005792),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text('Admin Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 'employee');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Color(0xFF0A9396),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text('Employee Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
