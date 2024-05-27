import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tangankanan/services/auth_service.dart';

class ProjectCatalogPage extends StatelessWidget {
  const ProjectCatalogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for projects
    final List<Map<String, dynamic>> projects = [
      {
        'title': 'Project A',
        'description': 'Description of Project A',
        'percentFunded': 75,
        'backers': 150,
        'daysRemaining': 30,
        'imagePath': 'assets/images/project_a.jpg'
      },
      // Add more projects as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Catalog'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
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
                LinearProgressIndicator(value: project['percentFunded'] / 100),
                Text('${project['percentFunded']}% funded'),
                Text('${project['backers']} backers'),
                Text('${project['daysRemaining']} days remaining'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/project_details_page',
                        arguments: project);
                  },
                  child: Text('See Details'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
