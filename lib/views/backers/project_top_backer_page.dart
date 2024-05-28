import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/models/pledge.dart';
import 'package:tangankanan/models/user.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

class ProjectTopBackerPage extends StatefulWidget {
  final Project project;

  const ProjectTopBackerPage({Key? key, required this.project})
      : super(key: key);

  @override
  _ProjectTopBackerPageState createState() => _ProjectTopBackerPageState();
}

class _ProjectTopBackerPageState extends State<ProjectTopBackerPage> {
  late Future<List<Map<String, dynamic>>> _topBackersFuture;

  @override
  void initState() {
    super.initState();
    _topBackersFuture = _fetchTopBackers();
  }

  Future<List<Map<String, dynamic>>> _fetchTopBackers() async {
    List<Pledge> pledges = await DatabaseService()
        .fetchPledgesByProjectId(widget.project.projectId);
    Map<String, double> contributionsMap = {};

    for (Pledge pledge in pledges) {
      if (contributionsMap.containsKey(pledge.userId)) {
        contributionsMap[pledge.userId] =
            contributionsMap[pledge.userId]! + pledge.amount;
      } else {
        contributionsMap[pledge.userId] = pledge.amount;
      }
    }

    List<Map<String, dynamic>> topBackers = [];
    for (String userId in contributionsMap.keys) {
      User? user = await DatabaseService().fetchUserById(userId);
      if (user != null) {
        topBackers.add({
          'user': user,
          'amount': contributionsMap[userId]!,
        });
      }
    }

    topBackers.sort((a, b) => b['amount'].compareTo(a['amount']));
    return topBackers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Top Backers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _topBackersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No backers found.'));
          } else {
            List<Map<String, dynamic>> topBackers = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 4, 60, 158)),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RANK',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                      Text('BACKER',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                      Text('CONTRIBUTION',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ],
                  ),
                  Divider(
                      color: const Color.fromARGB(255, 64, 64, 64),
                      thickness: 2),
                  Expanded(
                    child: ListView.builder(
                      itemCount: topBackers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> backer = topBackers[index];
                        User user = backer['user'];
                        double amount = backer['amount'];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(0, 254, 255, 236),
                                    Colors.white
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${index + 1}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            user.profilePictureUrl),
                                      ),
                                      SizedBox(width: 8),
                                      Text(user.username,
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  Text('RM ${amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
