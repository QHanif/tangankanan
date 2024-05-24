import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/services/auth_service.dart';

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
    // Check if any of the fields are empty or if birthdate is not selected
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _birthdate == null) {
      // Check if birthdate is null
      setState(() {
        errorMessage = 'Please fill all fields and select a birthdate';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
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
      // Navigate to the appropriate page based on the role
      if (_role == 'backer') {
        Navigator.pushReplacementNamed(context, '/backerHomePage');
      } else if (_role == 'creator') {
        Navigator.pushReplacementNamed(context, '/creatorHomePage');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
    }
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
      children: <Widget>[
        Text(_birthdate == null
            ? 'No date chosen'
            : 'Chosen Date: ${_birthdate!.toIso8601String()}'),
        TextButton(
          onPressed: () {
            _selectDate(context);
          },
          child: Text('Choose Date'),
        ),
      ],
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false,
      required bool obscureText,
      required VoidCallback toggleVisibility}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: isPassword
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }

  Widget _roleSelection() {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Backer'),
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
          title: const Text('Creator'),
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
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage);
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: createUserWithEmailAndPassword,
      child: Text('Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _entryField('Username', _usernameController,
                  obscureText: false, toggleVisibility: () {}),
              _entryField('Email', _emailController,
                  obscureText: false, toggleVisibility: () {}),
              _entryField('Phone Number', _phoneNumberController,
                  obscureText: false, toggleVisibility: () {}),
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
              _birthdatePicker(context),
              _roleSelection(),
              _errorMessage(),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
