import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:tangankanan/views/style.dart';
import 'package:tangankanan/views/common/register_page.dart';
import 'package:tangankanan/views/common/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';
  bool _obscurePassword = true;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User signed in');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getFriendlyErrorMessage(e);
      });
    }
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false,
      bool obscureText = false,
      VoidCallback? toggleVisibility}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelStyle: TextStyle(color: Colors.black54),
          labelText: title,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: AppColors.textFieldBorder),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _errorMessage() {
    if (errorMessage == '') return Container();
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        errorMessage = '';
      });
    });
    return Text(
      'Error: $errorMessage',
      style: TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: signInWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "Register here!",
            style: TextStyle(
                color: Color(0xFF273DFF), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
          ),
        ],
      ),
    );
  }

  Widget _forgotPasswordButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
          );
        },
        child: Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.blue.shade900),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/icon/tangankanan_app_icon.png',
                height: 100,
              ),
              SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'T',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002FD8),
                      ),
                    ),
                    TextSpan(
                      text: 'angan',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF001561),
                      ),
                    ),
                    TextSpan(
                      text: 'k',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002FD8),
                      ),
                    ),
                    TextSpan(
                      text: 'anan',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF001561),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _entryField('Email', _emailController),
              SizedBox(height: 10),
              _entryField('Password', _passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword, toggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }),
              _forgotPasswordButton(),
              SizedBox(height: 10),
              _errorMessage(),
              SizedBox(height: 20),
              _submitButton(),
              SizedBox(height: 10),
              _signUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}
