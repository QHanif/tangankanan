import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tangankanan/models/user.dart';
import 'package:tangankanan/models/project.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> calculateTotalEarnings(String userId) async {
    double totalEarnings = 0.0;

    // Fetch the user document
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    // Convert the user document to a User object
    User user = User.fromJson(userDoc.data() as Map<String, dynamic>);

    // Fetch all projects created by the user
    for (String projectId in user.createdProjects) {
      DocumentSnapshot projectDoc =
          await _firestore.collection('projects').doc(projectId).get();
      if (projectDoc.exists) {
        Project project =
            Project.fromMap(projectDoc.data() as Map<String, dynamic>);
        totalEarnings += project.currentFund;
      }
    }

    return totalEarnings;
  }
}
