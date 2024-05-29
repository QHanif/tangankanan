import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/views/style.dart';

class CreatorProjectDetailsPage extends StatefulWidget {
  final Project project;

  const CreatorProjectDetailsPage({Key? key, required this.project})
      : super(key: key);

  @override
  _CreatorProjectDetailsPageState createState() =>
      _CreatorProjectDetailsPageState();
}

class _CreatorProjectDetailsPageState extends State<CreatorProjectDetailsPage> {
  late Future<String> _creatorNameFuture;
  late Future<Project> _projectFuture;

  @override
  void initState() {
    super.initState();
    _creatorNameFuture = _fetchCreatorName(widget.project.creatorId);
    _projectFuture = _fetchProjectDetails(widget.project.projectId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _creatorNameFuture = _fetchCreatorName(widget.project.creatorId);
      _projectFuture = _fetchProjectDetails(widget.project.projectId);
    });
    await Future.wait([_creatorNameFuture, _projectFuture]);
  }

  Future<String> _fetchCreatorName(String creatorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(creatorId)
        .get();
    return doc['username'];
  }

  Future<Project> _fetchProjectDetails(String projectId) async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get();
    return Project.fromDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Project Details'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: AppStyles().cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                widget.project.projectPicUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<String>(
                            future: _creatorNameFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  'Created by ${snapshot.data}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<Project>(
                            future: _projectFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final project = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      project.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    _buildInfoRow('Fund Received',
                                        'RM ${project.currentFund.toStringAsFixed(2)}'),
                                    _buildInfoRow('Fund Goals',
                                        'RM ${project.fundGoal.toStringAsFixed(2)}'),
                                    _buildInfoRow('Percent Funded',
                                        '${(project.currentFund / project.fundGoal * 100).toStringAsFixed(1)}%'),
                                    _buildInfoRow(
                                        'Backers', '${project.backers.length}'),
                                    _buildInfoRow(
                                      'Time Remaining',
                                      () {
                                        final duration = project.endDate
                                            .difference(DateTime.now());
                                        if (duration.inDays >= 2) {
                                          return '${duration.inDays} days';
                                        } else {
                                          return '${duration.inHours} hours';
                                        }
                                      }(),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      AppStyles.buttonWithIcon(
                        'View Funding Progress',
                        Icons.show_chart,
                        () {
                          Navigator.pushNamed(context, '/fundingProgress',
                              arguments: widget.project);
                        },
                      ),
                      SizedBox(height: 10),
                      AppStyles.buttonWithIcon(
                        'Post Community Update',
                        Icons.update,
                        () {
                          Navigator.pushNamed(
                              context, '/community_updates_page',
                              arguments: widget.project);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
