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
    Timestamp? createdAtTimestamp;
    try {
      createdAtTimestamp = data['createdAt'] as Timestamp?;
    } catch (e) {
      createdAtTimestamp = null;
    }

    String? phoneNumber;
    try {
      phoneNumber = data['phoneNumber'] as String?;
    } catch (e) {
      phoneNumber = null;
    }

    DateTime? dateOfBirth;
    try {
      dateOfBirth = data['dateOfBirth'] != null ? (data['dateOfBirth'] as Timestamp).toDate() : null;
    } catch (e) {
      dateOfBirth = null;
    }

    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      createdAt: createdAtTimestamp != null ? createdAtTimestamp.toDate() : DateTime.now(),
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
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
