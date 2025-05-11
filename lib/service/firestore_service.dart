import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data to Firestore with customizable role
  Future<void> saveUserData(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to save user data: \$e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      throw Exception('Failed to update user role: \$e');
    }
  }

  // Get user data by UID
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: \$e');
    }
  }

  // Fetch all company policies
  Future<List<Map<String, dynamic>>> fetchCompanyPolicies() async {
    try {
      final querySnapshot = await _firestore.collection('policies').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch company policies: \$e');
    }
  }

  // Fetch salary slips for a specific user
  Future<List<Map<String, dynamic>>> fetchSalarySlips(String uid) async {
    try {
      final querySnapshot = await _firestore.collection('salary_slips').doc(uid).collection('slips').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch salary slips: \$e');
    }
  }

  // Fetch upcoming events
  Future<List<Map<String, dynamic>>> fetchUpcomingEvents() async {
    try {
      final querySnapshot = await _firestore.collection('events').orderBy('date').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: \$e');
    }
  }

  // Fetch attendance records for a specific user
  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(String uid) async {
    try {
      final userAttendanceDoc = await _firestore.collection('attendance').doc(uid).get();
      if (!userAttendanceDoc.exists) {
        return [];
      }
      final data = userAttendanceDoc.data()!;
      List<Map<String, dynamic>> records = [];
      data.forEach((date, record) {
        records.add({
          'date': date,
          'status': record['status'] ?? 'Unknown',
          'checkIn': record['checkIn'],
          'checkOut': record['checkOut'],
        });
      });
      return records;
    } catch (e) {
      throw Exception('Failed to fetch attendance records: \$e');
    }
  }

  // Mark check-in for a user on a specific date
  Future<void> markCheckIn(String uid, String date, String checkInTime) async {
    try {
      final docRef = _firestore.collection('attendance').doc(uid);
      final doc = await docRef.get();
      Map<String, dynamic> attendanceData = {};
      if (doc.exists) {
        attendanceData = doc.data()!;
      }
      attendanceData[date] = {
        'status': 'Present',
        'checkIn': checkInTime,
        'checkOut': attendanceData[date]?['checkOut'],
      };
      await docRef.set(attendanceData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to mark check-in: \$e');
    }
  }

  // Mark check-out for a user on a specific date
  Future<void> markCheckOut(String uid, String date, String checkOutTime) async {
    try {
      final docRef = _firestore.collection('attendance').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('No check-in record found for user on this date');
      }
      Map<String, dynamic> attendanceData = doc.data()!;
      if (!attendanceData.containsKey(date)) {
        throw Exception('No check-in record found for user on this date');
      }
      attendanceData[date] = {
        'status': 'Present',
        'checkIn': attendanceData[date]['checkIn'],
        'checkOut': checkOutTime,
      };
      await docRef.set(attendanceData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to mark check-out: \$e');
    }
  }

  // Fetch all employees' attendance for a specific date
  Future<Map<String, Map<String, dynamic>>> fetchAllAttendanceByDate(String date) async {
    try {
      final querySnapshot = await _firestore.collection('attendance').get();
      Map<String, Map<String, dynamic>> allAttendance = {};
      for (var doc in querySnapshot.docs) {
        final uid = doc.id;
        final data = doc.data();
        if (data.containsKey(date)) {
          allAttendance[uid] = Map<String, dynamic>.from(data[date]);
        }
      }
      return allAttendance;
    } catch (e) {
      throw Exception('Failed to fetch all attendance by date: \$e');
    }
  }

  // Update attendance entry for a user on a specific date (admin)
  Future<void> updateAttendanceEntry(String uid, String date, Map<String, dynamic> updatedData) async {
    try {
      final docRef = _firestore.collection('attendance').doc(uid);
      final doc = await docRef.get();
      Map<String, dynamic> attendanceData = {};
      if (doc.exists) {
        attendanceData = doc.data()!;
      }
      attendanceData[date] = updatedData;
      await docRef.set(attendanceData);
    } catch (e) {
      throw Exception('Failed to update attendance entry: \$e');
    }
  }
}
