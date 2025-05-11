import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  LoginScreen({Key? key, this.role = 'employee'}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void loginUser() async {
    setState(() => isLoading = true);
    await AuthService().loginUser(
      email: emailController.text,
      password: passwordController.text,
      context: context,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;

    return Scaffold(
      appBar: AppBar(title: Text("${role.toLowerCase() == 'admin' ? 'Admin' : 'Employee'} Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                SizedBox(height: 24),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: loginUser,
                        child: Text("Login"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Color(0xFF005792),
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/signup"),
                  child: Text(
                    "New user? Sign up",
                    style: TextStyle(color: Color(0xFF005792), fontWeight: FontWeight.w600),
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
