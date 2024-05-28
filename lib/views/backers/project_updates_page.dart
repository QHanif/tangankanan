import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/models/update.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

class ProjectUpdatesPage extends StatefulWidget {
  final Project project;

  const ProjectUpdatesPage({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectUpdatesPageState createState() => _ProjectUpdatesPageState();
}

class _ProjectUpdatesPageState extends State<ProjectUpdatesPage> {
  late Future<List<Update>> _updatesFuture;

  @override
  void initState() {
    super.initState();
    _updatesFuture = _fetchUpdates();
  }

  Future<List<Update>> _fetchUpdates() async {
    return await DatabaseService()
        .fetchUpdatesByProjectId(widget.project.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Project Updates'),
      ),
      body: FutureBuilder<List<Update>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No updates found.'));
          } else {
            List<Update> updates = snapshot.data!;
            return ListView.builder(
              itemCount: updates.length,
              itemBuilder: (context, index) {
                Update update = updates[index];
                return Card(
                  color: Colors.white, // Set the card color to white
                  margin: EdgeInsets.all(10.0),
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
                          Text(
                            update.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (update.imageUrl != null) ...[
                            SizedBox(height: 10),
                            Container(
                              height: 200, // Fixed height for all images
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  update.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                          SizedBox(height: 10),
                          Text(
                            '${update.date.toLocal()}'.split(' ')[0],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(update.description),
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
