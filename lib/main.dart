import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'home/admin_home.dart';
import 'home/employee_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Connect',
      theme: ThemeData(
        primaryColor: Color(0xFF005792),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF0A9396),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF005792),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF005792),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            minimumSize: Size(double.infinity, 48),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF005792),
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF005792)),
          ),
          labelStyle: TextStyle(color: Color(0xFF005792)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/admin_home': (context) => AdminHome(),
        '/employee_home': (context) => EmployeeHome(),
      },
    );
  }
}
