import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // 🔐 Register new user (always as employee)
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    DateTime? dateOfBirth,
    required BuildContext context,
  }) async {
    try {
      // Firebase Auth: Create user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Build employee user object (role is hardcoded)
      AppUser newUser = AppUser(
        uid: userCred.user!.uid,
        name: name,
        email: email,
        role: 'employee', // only employee allowed to register
        createdAt: DateTime.now(),
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      // Firestore: Save user data
      await _firestoreService.saveUserData(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful! Please log in.")),
      );
      Navigator.pushReplacementNamed(context, "/");

    } catch (e) {
      debugPrint("Register error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${e.toString()}")),
      );
    }
  }

  // 🔓 Login user & redirect based on role
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      debugPrint("Attempting login for email: $email");
      // Firebase Auth: Sign in
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;
      debugPrint("Firebase Auth successful, UID: $uid");

      // Firestore: Get user by ID
      final fetchedUser = await _firestoreService.getUserById(uid);
      if (fetchedUser == null) {
        throw Exception("User record not found");
      }
      debugPrint("Fetched user data from Firestore: ${fetchedUser.toMap()}");

      AppUser user = fetchedUser;

      // Redirect to dashboard based on role
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_home', arguments: user);
      } else {
        Navigator.pushReplacementNamed(context, '/employee_home', arguments: user);
      }

    } catch (e, stacktrace) {
      debugPrint("Login error: $e");
      debugPrint("Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  // 👤 Get user details by UID
  Future<AppUser?> getUserDetails(String uid) async {
    try {
      return await _firestoreService.getUserById(uid);
    } catch (e) {
      debugPrint("GetUser error: $e");
      return null;
    }
  }

  // 🚪 Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
  }
}
