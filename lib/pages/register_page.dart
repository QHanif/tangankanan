import 'package:flutter/material.dart';
// import 'package:tangankanan/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ?' + errorMessage);
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: createUserWithEmailAndPassword,
      child: Text('Register'),
    );
  }

  Widget _loginButton() {
    return TextButton(
      child: Text("Already have an account? Login"),
      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginPage()),
        // );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _entryField('Email', _emailController),
            _entryField('Password', _passwordController),
            _errorMessage(),
            _submitButton(),
            _loginButton(),
          ],
        ),
      ),
    );
  }
}
