import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/views/backers/payment_page.dart';
import 'package:tangankanan/views/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
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

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share this project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareIcon(
                      'assets/share_icon/fb.png', 'Facebook', context),
                  _buildShareIcon(
                      'assets/share_icon/ig.png', 'Instagram', context),
                  _buildShareIcon(
                      'assets/share_icon/x.png', 'X (Twitter)', context),
                  _buildShareIcon(
                      'assets/share_icon/wa.png', 'WhatsApp', context),
                ],
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(String assetPath, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Share.share(
            'Check out this project: ${widget.project.title} in Tangankanan App\n\n');
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Image.asset(assetPath, height: 40, width: 40),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Project Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _showShareOptions(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
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
                              } else if (!snapshot.hasData) {
                                return Text('Project not found');
                              } else {
                                Project project = snapshot.data!;
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
                      AppStyles.buttonWithIcon('Latest Update', Icons.update,
                          () {
                        Navigator.pushNamed(context, '/projectUpdates',
                            arguments: widget.project);
                      }),
                      AppStyles.buttonWithIcon('View Top Backers', Icons.people,
                          () {
                        Navigator.pushNamed(context, '/projectTopBackers',
                            arguments: widget.project);
                      }),
                      AppStyles.buttonWithIcon(
                          'Support This Project', Icons.payment, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentPage(project: widget.project),
                          ),
                        ).then((_) {
                          _refreshData(); // Refresh project details when returning from PaymentPage
                        });
                      }),
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
