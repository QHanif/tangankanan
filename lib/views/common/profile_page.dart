import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/common/update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = Auth().currentUser;
  Map<String, dynamic>? userData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (user != null) {
        userData = await DatabaseService().getUserData(user!.uid);
        setState(() {});
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _navigateToUpdateProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateProfilePage()),
    );

    if (result == true) {
      // Refresh the user data if the profile was updated
      _loadUserData();
    }
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: () async {
        await Auth().signOut();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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
      body: userData == null
          ? errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                _signOutButton(),
                _userUid(),
                Card(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                            userData!['profilePictureUrl'] ??
                                'https://via.placeholder.com/150'),
                      ),
                      Text(userData!['username'] ?? 'No username'),
                      Text(userData!['email'] ?? 'No email'),
                      Text(userData!['phoneNumber'] ?? 'No phone'),
                      Text(userData!['registerDate'] ?? 'No register date'),
                      Text('Role: ${userData!['role'] ?? 'No role'}'),
                    ],
                  ),
                ),
                if (userData!['role'] == 'backer') ...[
                  TextButton(
                    onPressed: _navigateToUpdateProfile,
                    child: Text('Update Information'),
                  ),
                  Container(
                    child: Text(
                        'Total Contribution: \$${userData!['total_contribution'] ?? 0}'),
                  ),
                  Container(
                    child: Text(
                        'Total Projects Backed: ${userData!['total_projects_backed'] ?? 0}'),
                  ),
                  Container(
                    child: Text(
                        'Recent Contribution: ${userData!['recent_contribution'] ?? 'No recent contribution'}'),
                  ),
                ] else if (userData!['role'] == 'creator') ...[
                  TextButton(
                    onPressed: _navigateToUpdateProfile,
                    child: Text('Update Information'),
                  ),
                  Container(
                    child: Text(
                        'Total Projects Created: ${userData!['total_projects_created'] ?? 0}'),
                  ),
                  Container(
                    child: Text(
                        'Total Earnings: \$${userData!['total_earnings'] ?? 0}'),
                  ),
                ],
              ],
            ),
    );
  }
}
