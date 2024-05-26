import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final String role; // Add a parameter to receive the user role

  ProfilePage({Key? key, required this.role}) : super(key: key);

  final User? user = Auth().currentUser;

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: () async {
        await Auth().signOut();
      },
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        children: <Widget>[
          _signOutButton(),
          _userUid(),
          Card(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage('https://example.com/profile_pic.jpg'),
                ),
                Text('Username'),
                Text('Email'),
                Text('Phone No'),
                Text('Register Date'),
                Text('Role: $role'), // Display the role
              ],
            ),
          ),
          if (role == 'backer') ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/updateProfile');
              },
              child: Text('Update Information'),
            ),
            Container(
              child: Text('Total Contribution: \$Amount'),
            ),
            Container(
              child: Text('Total Projects Backed: Number'),
            ),
            Container(
              child: Text('Recent Contribution: Project Title - \$Amount'),
            ),
          ] else if (role == 'creator') ...[
            // Add different widgets for the creator role
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manageProjects');
              },
              child: Text('Manage Projects'),
            ),
            Container(
              child: Text('Total Projects Created: Number'),
            ),
            Container(
              child: Text('Total Earnings: \$Amount'),
            ),
          ],
        ],
      ),
    );
  }
}
