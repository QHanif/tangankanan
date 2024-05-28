import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

class ProjectVerificationPage extends StatelessWidget {
  final Project project;

  const ProjectVerificationPage({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verify Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(project.projectPicUrl),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          project.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        project.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Fund Goal:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '\$${project.fundGoal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Current Fund:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '\$${project.currentFund.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Start Date:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${project.startDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'End Date:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${project.endDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Verification Status:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${project.verificationStatus}',
                              style: TextStyle(
                                fontSize: 16,
                                color: project.verificationStatus == 'verified'
                                    ? Colors.green
                                    : project.verificationStatus == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Project Status:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${project.projectStatus}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle project verification
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Verify Project'),
                            content: Text(
                                'Are you sure you want to verify this project?'),
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
                                  await DatabaseService()
                                      .updateProjectVerificationStatus(
                                          project.projectId, 'verified');
                                  Navigator.of(context)
                                      .pop(); // Dismiss alert dialog
                                  Navigator.of(context)
                                      .pop(); // Go back to the previous page
                                },
                                child: Text('Verify'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child:
                        Text('Verify', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle project rejection
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Reject Project'),
                            content: Text(
                                'Are you sure you want to reject this project?'),
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
                                  await DatabaseService()
                                      .updateProjectVerificationStatus(
                                          project.projectId, 'rejected');
                                  Navigator.of(context)
                                      .pop(); // Dismiss alert dialog
                                  Navigator.of(context)
                                      .pop(); // Go back to the previous page
                                },
                                child: Text('Reject'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child:
                        Text('Reject', style: TextStyle(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
