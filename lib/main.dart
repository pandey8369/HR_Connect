import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/role_selection_screen.dart';
import 'screens/admin/admin_home.dart';
import 'screens/admin/send_notification.dart';
import 'screens/admin/reset_password.dart';
import 'screens/employee/employee_home.dart';
import 'screens/employee/view_notifications.dart';
import 'screens/employee/profile_settings.dart';

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
        '/': (context) => RoleSelectionScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/admin_home': (context) => AdminHome(),
        '/send_notification': (context) => SendNotification(),
        '/reset_password': (context) => ResetPassword(),
        '/employee_home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return EmployeeHome(user: args as dynamic);
        },
        '/view_notifications': (context) {
          return ViewNotifications();
        },
        '/profile_settings': (context) {
          return ProfileSettings();
        },
      },
    );
  }
}
