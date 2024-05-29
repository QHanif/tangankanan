import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

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
      await _checkAndUpdateProjectStatus();
    }
  }

  Future<void> _refreshProjects() async {
    await _loadUserProjects();
    _loadUserProfilePicture();
  }

  Future<void> _checkAndUpdateProjectStatus() async {
    for (var project in _projects) {
      if (project.endDate.isBefore(DateTime.now()) &&
          project.projectStatus != 'completed') {
        await DatabaseService()
            .updateProjectStatus(project.projectId, 'completed');
      }
    }
  }

  Widget _text(argument) {
    return Text(
      argument,
      style: TextStyle(
        color: AppColors.primaryButton,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: _profilePictureUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(_profilePictureUrl!),
                )
              : Icon(Icons.account_circle),
          onPressed: () async {
            await Navigator.pushNamed(context, '/profile').then((_) {
              _loadUserProfilePicture(); // Refresh profile picture when returning from profile page
            });
          },
        ),
        title: Text('Your Project'),
        centerTitle: true,
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
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 16.0, right: 16.0, bottom: 100.0),
          child: _projects.isEmpty
              ? Center(child: Text('No projects created yet.'))
              : ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration: AppStyles().cardDecoration(),
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
                                color: AppColors.primaryButton,
                              ),
                              SizedBox(height: 5),
                              _text(
                                  '${(project.currentFund / project.fundGoal * 100).toStringAsFixed(1)}% funded'),
                              SizedBox(height: 5),
                              _text('${project.backers.length} backers'),
                              SizedBox(height: 5),
                              _text(
                                () {
                                  if (project.projectStatus == 'completed') {
                                    return 'Project Completed';
                                  }
                                  final duration = project.endDate
                                      .difference(DateTime.now());
                                  if (duration.inDays >= 2) {
                                    return '${duration.inDays} days remaining';
                                  } else {
                                    return '${duration.inHours} hours remaining';
                                  }
                                }(),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    project.verificationStatus == 'verified'
                                        ? Icons.verified
                                        : project.verificationStatus ==
                                                'rejected'
                                            ? Icons.cancel
                                            : Icons.error,
                                    color:
                                        project.verificationStatus == 'verified'
                                            ? Colors.green
                                            : project.verificationStatus ==
                                                    'rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    project.verificationStatus == 'verified'
                                        ? 'Verified'
                                        : project.verificationStatus ==
                                                'rejected'
                                            ? 'Rejected'
                                            : 'Pending',
                                    style: TextStyle(
                                      color: project.verificationStatus ==
                                              'verified'
                                          ? Colors.green
                                          : project.verificationStatus ==
                                                  'rejected'
                                              ? Colors.red
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/creatorProjectDetails',
                                        arguments: project,
                                      );
                                    },
                                    style:
                                        AppStyles.primaryButtonStyle.copyWith(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 10.0)),
                                    ),
                                    child: Text(
                                      'See details',
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createProject').then((_) {
                _loadUserProjects(); // Reload projects when returning from create project page
              });
            },
            style: AppStyles.primaryButtonStyle,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Create new project',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
