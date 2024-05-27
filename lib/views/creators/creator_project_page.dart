import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';

class CreatorProjectPage extends StatefulWidget {
  const CreatorProjectPage({Key? key}) : super(key: key);

  @override
  _CreatorProjectPageState createState() => _CreatorProjectPageState();
}

class _CreatorProjectPageState extends State<CreatorProjectPage> {
  String? _profilePictureUrl;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfilePicture();
    _loadUserProjects();
  }

  Future<void> _loadUserProfilePicture() async {
    final userId = Auth().currentUser?.uid;
    if (userId != null) {
      final user = await DatabaseService().fetchUserById(userId);
      setState(() {
        _profilePictureUrl = user?.profilePictureUrl;
      });
    }
  }

  Future<void> _loadUserProjects() async {
    final userId = Auth().currentUser?.uid;
    if (userId != null) {
      final projects = await DatabaseService().fetchProjectsByCreatorId(userId);
      setState(() {
        _projects = projects;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: _profilePictureUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(_profilePictureUrl!),
                )
              : Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: Text('Your Projects'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notification_page');
            },
          ),
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
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        project.projectPicUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      project.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      project.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: project.currentFund / project.fundGoal,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${(project.currentFund / project.fundGoal * 100).toStringAsFixed(2)}% funded',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${project.backers.length} backers',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${project.endDate.difference(DateTime.now()).inDays} days remaining',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/creator_project_details_page',
                          arguments: project,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('See Details'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createProject').then((_) {
            _loadUserProjects(); // Reload projects when returning from create project page
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Create New Project',
      ),
    );
  }
}
