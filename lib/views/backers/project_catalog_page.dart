import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

class ProjectCatalogPage extends StatefulWidget {
  const ProjectCatalogPage({Key? key}) : super(key: key);

  @override
  _ProjectCatalogPageState createState() => _ProjectCatalogPageState();
}

class _ProjectCatalogPageState extends State<ProjectCatalogPage> {
  String? _profilePictureUrl;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfilePicture();
    _loadVerifiedProjects();
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

  Future<void> _loadVerifiedProjects() async {
    final projects = await DatabaseService().fetchVerifiedProjects();
    setState(() {
      _projects = projects;
    });
  }

  Future<void> _refreshProjects() async {
    await _loadVerifiedProjects();
    _loadUserProfilePicture();
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
              _loadVerifiedProjects();
            });
          },
        ),
        title: Text('Project Catalog'),
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
          padding: const EdgeInsets.all(16.0), // Adjusted padding
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(0, 206, 200, 252), Colors.white],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Adjusted padding
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
                        FutureBuilder<String>(
                          future: DatabaseService()
                              .fetchCreatorName(project.creatorId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  children: [
                                    TextSpan(text: 'Created by '),
                                    TextSpan(
                                      text: snapshot.data,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
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
                        _text(() {
                          final duration =
                              project.endDate.difference(DateTime.now());
                          if (duration.inDays >= 2) {
                            return '${duration.inDays} days to go';
                          } else {
                            return '${duration.inHours} hours to go';
                          }
                        }()),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: project.projectStatus == 'ongoing'
                                      ? Colors.green
                                      : Colors.blue,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '${project.projectStatus.toUpperCase()}',
                                style: TextStyle(
                                  color: project.projectStatus == 'ongoing'
                                      ? Colors.green
                                      : Colors.blue,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/projectDetails',
                                  arguments: project,
                                ).then((_) {
                                  _loadVerifiedProjects();
                                });
                              },
                              style: AppStyles.primaryButtonStyle.copyWith(
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
    );
  }
}
