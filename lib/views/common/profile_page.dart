import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tangankanan/models/pledge.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/services/project_service.dart';
import 'package:tangankanan/views/common/update_profile_page.dart';
import 'package:tangankanan/views/style.dart';

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
        if (userData != null) {
          if (userData!['role'] == 'creator') {
            double totalEarnings =
                await UserService().calculateTotalEarnings(user!.uid);
            userData!['total_earnings'] = totalEarnings;

            // Fetch total projects created by the user
            List<Project> createdProjects =
                await DatabaseService().fetchProjectsByCreatorId(user!.uid);
            userData!['total_projects_created'] = createdProjects.length;
          } else if (userData!['role'] == 'backer') {
            List<Pledge> pledges =
                await DatabaseService().fetchPledgesByUserId(user!.uid);
            double totalContribution =
                pledges.fold(0, (sum, pledge) => sum + pledge.amount);
            userData!['total_contribution'] = totalContribution;

            Map<String, double> contributionsMap = {};
            for (Pledge pledge in pledges) {
              Project project =
                  await DatabaseService().fetchProjectById(pledge.projectId);
              if (contributionsMap.containsKey(project.title)) {
                contributionsMap[project.title] =
                    contributionsMap[project.title]! + pledge.amount;
              } else {
                contributionsMap[project.title] = pledge.amount;
              }
            }

            List<MapEntry<String, double>> sortedContributions =
                contributionsMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

            userData!['recent_contributions'] = sortedContributions;
          }
        }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: userData == null
          ? errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                    userData!['profilePictureUrl'] ??
                                        'https://via.placeholder.com/150'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                userData!['username'] ?? 'No username',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildUserInfoRow(
                                  'Username', userData!['username']),
                              _buildUserInfoRow('Email', userData!['email']),
                              _buildUserInfoRow(
                                  'Phone No', userData!['phoneNumber']),
                              _buildUserInfoRow(
                                  'Register Date',
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(
                                          userData!['registerDate']))),
                              _buildUserInfoRow(
                                  'Date of Birth',
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(userData!['birthdate']))),
                              _buildUserInfoRow('Role', userData!['role']),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToUpdateProfile,
                    child: Text('Update Profile',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: AppStyles.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 10.0)),
                    ),
                  ),
                  if (userData!['role'] == 'creator') ...[
                    _buildInfoCard('Total Funds Collected',
                        'RM ${userData!['total_earnings']?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildInfoCard('Total Projects Created',
                        '${userData!['total_projects_created'] ?? 0}'),
                  ] else if (userData!['role'] == 'backer') ...[
                    _buildInfoCard('Total Contribution',
                        'RM ${userData!['total_contribution']?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildRecentContributions(userData!['recent_contributions']
                        as List<MapEntry<String, double>>),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryButton,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentContributions(
      List<MapEntry<String, double>> contributions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recent Contributions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...contributions.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(entry.key),
                          Text('RM ${entry.value.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
