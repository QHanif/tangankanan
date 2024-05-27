import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/views/style.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please enter your email address to receive a password reset link.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black54),
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: AppColors.textFieldBorder),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: Text('Send Password Reset Email'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password reset email sent!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send password reset email: $e')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
