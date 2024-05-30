import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/views/style.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'backer'; // Default role
  String errorMessage = '';
  DateTime? _birthdate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> createUserWithEmailAndPassword() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _birthdate == null) {
      setState(() {
        errorMessage = 'Please fill all fields and select a birthdate';
      });
      await _clearErrorMessage();
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      await _clearErrorMessage();
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
        username: _usernameController.text,
        phoneNumber: _phoneNumberController.text,
        birthdate: _birthdate,
      );
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful! Logging you in...'),
          duration: Duration(seconds: 4),
        ),
      );
      // Wait for 3 seconds
      await Future.delayed(Duration(seconds: 1));
      // Navigate to login page
      Navigator.of(context).pushReplacementNamed('/');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
      await _clearErrorMessage();
    }
  }

  Future<void> _clearErrorMessage() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      errorMessage = '';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != _birthdate) {
      setState(() {
        _birthdate = picked;
      });
    }
  }

  Widget _birthdatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.calendar_today),
        SizedBox(width: 10),
        Text(
          'Birthday: ${_birthdate == null ? 'No date chosen' : _birthdate!.toIso8601String().substring(0, 10)}',
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            _selectDate(context);
          },
          icon: Icon(Icons.date_range),
          label: Text('Choose Date'),
        ),
      ],
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false,
      required bool obscureText,
      required VoidCallback toggleVisibility}) {
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

  Widget _roleSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Row(
              children: [
                const Text('Backer'),
                SizedBox(width: 5),
                Tooltip(
                  message: 'A backer supports projects by funding them.',
                  child: Icon(Icons.help_outline, size: 16),
                  showDuration: Duration(seconds: 2),
                  waitDuration: Duration(milliseconds: 1),
                ),
              ],
            ),
            leading: Radio<String>(
              value: 'backer',
              groupValue: _role,
              onChanged: (String? value) {
                setState(() {
                  _role = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Project Creator'),
                SizedBox(width: 5),
                Tooltip(
                  message: 'A project creator initiates and manages projects.',
                  child: Icon(Icons.help_outline, size: 16),
                  showDuration: Duration(seconds: 2),
                  waitDuration: Duration(milliseconds: 1),
                ),
              ],
            ),
            leading: Radio<String>(
              value: 'creator',
              groupValue: _role,
              onChanged: (String? value) {
                setState(() {
                  _role = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: createUserWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Register',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _entryField('Username', _usernameController,
                obscureText: false, toggleVisibility: () {}),
            _entryField('Email', _emailController,
                obscureText: false, toggleVisibility: () {}),
            _entryField('Phone Number', _phoneNumberController,
                obscureText: false, toggleVisibility: () {}),
            SizedBox(height: 10),
            _birthdatePicker(context),
            SizedBox(height: 15),
            _roleSelection(),
            SizedBox(height: 10),
            _entryField('Password', _passwordController,
                isPassword: true,
                obscureText: _obscurePassword, toggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            }),
            _entryField('Confirm Password', _confirmPasswordController,
                isPassword: true,
                obscureText: _obscureConfirmPassword, toggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            }),
            _errorMessage(),
            _submitButton(),
          ],
        ),
      ),
    );
  }
}
