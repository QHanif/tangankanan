import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/admin/manage_projects_page.dart';
import 'package:tangankanan/views/admin/manage_users_page.dart';
import 'package:tangankanan/views/admin/admin_create_project_page.dart';
import 'package:tangankanan/views/style.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _pendingApprovalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPendingApprovalCount();
    _checkAndUpdateProjectStatus();
  }

  Future<void> _fetchPendingApprovalCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('verificationStatus', isEqualTo: 'pending')
        .get();

    setState(() {
      _pendingApprovalCount = querySnapshot.docs.length;
    });
  }

  Future<void> _checkAndUpdateProjectStatus() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('projects').get();

    for (var doc in querySnapshot.docs) {
      final project = Project.fromDocument(doc);
      if (project.endDate.isBefore(DateTime.now()) &&
          project.projectStatus != 'completed') {
        await DatabaseService()
            .updateProjectStatus(project.projectId, 'completed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Center(child: Text('Admin Dashboard')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Auth().signOut();
              // Handle user logout
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/icon/tangankanan_app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome, Tangankanan Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            _buildCard(
              context,
              'Manage Projects',
              Icons.admin_panel_settings,
              ManageProjectsPage(),
              _pendingApprovalCount,
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              'Create New Project',
              Icons.assignment,
              AdminCreateProjectPage(),
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              'Manage Users',
              Icons.people,
              ManageUsersPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget page,
      [int? count]) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
        _fetchPendingApprovalCount(); // Refresh the notification dot when coming back
      },
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: AppStyles().cardDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(icon, size: 40, color: Colors.blue),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
          if (count != null && count > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
