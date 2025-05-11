import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? selectedDate;

  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void signup() async {
    setState(() => isLoading = true);
    try {
      await AuthService().registerUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phoneNumber: phoneController.text,
        dateOfBirth: selectedDate,
        context: context,
      );
      setState(() => isLoading = false);
      // Show alert dialog on successful registration
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('Your registration is complete. Please log in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      selectedDate == null ? 'Select Date' : "${selectedDate!.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: signup,
                        child: Text("Register"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Color(0xFF005792),
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
