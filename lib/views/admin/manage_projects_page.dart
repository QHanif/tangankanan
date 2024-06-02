import 'package:flutter/material.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/views/admin/project_verification_page.dart';
import 'package:tangankanan/views/admin/update_project_page.dart';
import 'package:tangankanan/views/style.dart';

class ManageProjectsPage extends StatefulWidget {
  const ManageProjectsPage({Key? key}) : super(key: key);

  @override
  _ManageProjectsPageState createState() => _ManageProjectsPageState();
}

class _ManageProjectsPageState extends State<ManageProjectsPage> {
  late Future<List<Project>> _pendingProjects;

  @override
  void initState() {
    super.initState();
    _fetchPendingProjects();
  }

  void _fetchPendingProjects() {
    setState(() {
      _pendingProjects = DatabaseService().fetchPendingProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Projects'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _pendingProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending projects'));
          } else {
            final projects = snapshot.data!;
            projects.sort((a, b) {
              if (a.verificationStatus == 'pending' &&
                  b.verificationStatus != 'pending') {
                return -1;
              } else if (a.verificationStatus != 'pending' &&
                  b.verificationStatus == 'pending') {
                return 1;
              } else {
                return 0;
              }
            });
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 10,
                  child: Container(
                    decoration: AppStyles().cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              project.projectPicUrl,
                              height: 200,
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
                          Text(project.description),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        project.verificationStatus == 'verified'
                                            ? Colors.green
                                            : project.verificationStatus ==
                                                    'rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Text(
                                  'Status: ${project.verificationStatus.toUpperCase()}',
                                  style: TextStyle(
                                    color:
                                        project.verificationStatus == 'verified'
                                            ? Colors.green
                                            : project.verificationStatus ==
                                                    'rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateProjectPage(
                                                  project: project),
                                        ),
                                      );
                                      _fetchPendingProjects(); // Refresh the list when coming back
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () async {
                                      // Handle project deletion
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Delete Project'),
                                            content: Text(
                                                'Are you sure you want to delete this project?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Dismiss alert dialog
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await DatabaseService()
                                                        .deleteProject(
                                                            project.projectId);
                                                    await DatabaseService()
                                                        .deleteProjectImage(
                                                            project.projectId);
                                                    print(
                                                        'Project and image deleted successfully');
                                                  } catch (e) {
                                                    print(
                                                        'Error deleting project or image: $e');
                                                  }
                                                  Navigator.of(context)
                                                      .pop(); // Dismiss alert dialog
                                                  _fetchPendingProjects(); // Refresh the list
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          AppStyles.button(
                            'View Details',
                            () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProjectVerificationPage(project: project),
                                ),
                              );
                              _fetchPendingProjects(); // Refresh the list when coming back
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
