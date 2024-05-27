import 'package:flutter/material.dart';
import 'package:tangankanan/services/auth_service.dart';

class AdminProjectCatalogPage extends StatelessWidget {
  const AdminProjectCatalogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for project applications
    final List<Map<String, dynamic>> projects = [
      {
        'title': 'Project A',
        'description': 'Description of Project A',
        'imagePath': 'assets/images/project_a.jpg'
      },
      // Add more projects as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Applications'),
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
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            child: Column(
              children: [
                Image.asset(project['imagePath']),
                Text(project['title'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(project['description']),
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
                                  onPressed: () {
                                    // Logic to verify project
                                    Navigator.of(context)
                                        .pop(); // Dismiss alert dialog
                                  },
                                  child: Text('Verify'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Verify'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
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
                                  onPressed: () {
                                    // Logic to reject project
                                    Navigator.of(context)
                                        .pop(); // Dismiss alert dialog
                                  },
                                  child: Text('Reject'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Reject'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
