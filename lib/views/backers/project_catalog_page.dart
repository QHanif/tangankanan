import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/backers/project_details_page.dart';
import 'package:tangankanan/views/style.dart';

class ProjectCatalogPage extends StatefulWidget {
  const ProjectCatalogPage({Key? key}) : super(key: key);

  @override
  _ProjectCatalogPageState createState() => _ProjectCatalogPageState();
}

class _ProjectCatalogPageState extends State<ProjectCatalogPage> {
  String? _profilePictureUrl;
  List<Project> _projects = [];
  String _searchQuery = '';
  String _sortOption = 'Title';

  @override
  void initState() {
    super.initState();
    _loadUserProfilePicture();
    _loadVerifiedProjects();
  }

  List<Project> _filteredAndSortedProjects() {
    List<Project> filteredProjects = _projects
        .where((project) =>
            project.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_sortOption) {
      case 'Title':
        filteredProjects.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Date':
        filteredProjects.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case 'Funding':
        filteredProjects.sort((a, b) =>
            (b.currentFund / b.fundGoal).compareTo(a.currentFund / a.fundGoal));
        break;
    }

    return filteredProjects;
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 5),
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
              FutureBuilder<String>(
                future: DatabaseService().fetchCreatorName(project.creatorId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                if (project.projectStatus == 'completed') {
                  return '';
                }
                final duration = project.endDate.difference(DateTime.now());
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      project.projectStatus == 'ongoing'
                          ? 'ONGOING'
                          : 'COMPLETED',
                      style: TextStyle(
                        color: project.projectStatus == 'ongoing'
                            ? Colors.green
                            : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDetailsPage(project: project),
                        ),
                      );
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _checkAndUpdateProjectStatus() async {
    for (var project in _projects) {
      if (project.endDate.isBefore(DateTime.now()) &&
          project.projectStatus != 'completed') {
        await DatabaseService()
            .updateProjectStatus(project.projectId, 'completed');
      }
    }
  }

  Future<void> _loadVerifiedProjects() async {
    final projects = await DatabaseService().fetchVerifiedProjects();
    setState(() {
      _projects = projects;
    });
    await _checkAndUpdateProjectStatus();
  }

  Future<void> _refreshProjects() async {
    await _loadVerifiedProjects();
    _loadUserProfilePicture();
  }

  Widget _text(String argument) {
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
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search projects...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Title', 'Date', 'Funding'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
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
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: _filteredAndSortedProjects().length,
            itemBuilder: (context, index) {
              final project = _filteredAndSortedProjects()[index];
              return _buildProjectCard(project);
            },
          ),
        ),
      ),
    );
  }
}
