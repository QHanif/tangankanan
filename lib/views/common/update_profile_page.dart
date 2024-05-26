import 'package:flutter/material.dart';

class UpdateProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Column(
        children: <Widget>[
          Placeholder(
              fallbackHeight: 100), // Placeholder for profile picture upload
          TextField(
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
            ),
          ),
          TextButton(
            onPressed: () {
              // Save changes logic
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
