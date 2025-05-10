import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.dateOfBirth,
  });

  // Convert Firestore document to AppUser
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'] != null ? (data['dateOfBirth'] as Timestamp).toDate() : null,
    );
  }

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
    };
  }
}
