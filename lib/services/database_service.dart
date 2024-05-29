import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/pledge.dart';
import '../models/update.dart';
import '../models/user.dart'; // Make sure to import the User model
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Project CRUD Operations
  Future<List<Project>> fetchProjectsByCreatorId(String creatorId) async {
    var result = await _db
        .collection('projects')
        .where('creatorId', isEqualTo: creatorId)
        .get();
    return result.docs.map((doc) => Project.fromMap(doc.data())).toList();
  }

  Future<List<Project>> fetchProjects() async {
    var result = await _db.collection('projects').get();
    return result.docs.map((doc) => Project.fromMap(doc.data())).toList();
  }

  Future<void> addProject(Project project) async {
    await _db.collection('projects').add(project.toJson());
  }

  Future<void> updateProject(String id, Project project) async {
    await _db.collection('projects').doc(id).update(project.toJson());
  }

  Future<void> deleteProject(String id) async {
    try {
      // Fetch the project to get the creatorId
      DocumentSnapshot projectDoc =
          await _db.collection('projects').doc(id).get();
      if (projectDoc.exists) {
        String creatorId = projectDoc['creatorId'];

        // Delete the project document
        await _db.collection('projects').doc(id).delete();

        // Delete the project image
        await deleteProjectImage(id);

        // Remove the projectId from the creator's createdProjects array
        await _db.collection('users').doc(creatorId).update({
          'createdProjects': FieldValue.arrayRemove([id])
        });

        // Fetch and delete all pledges related to the project
        var pledgesSnapshot = await _db
            .collection('pledges')
            .where('projectId', isEqualTo: id)
            .get();
        for (var pledgeDoc in pledgesSnapshot.docs) {
          await _db.collection('pledges').doc(pledgeDoc.id).delete();

          // Update the user's backedProjects array
          String userId = pledgeDoc['userId'];
          await _db.collection('users').doc(userId).update({
            'backedProjects': FieldValue.arrayRemove([id])
          });
        }

        // Fetch and delete all updates related to the project
        var updatesSnapshot = await _db
            .collection('updates')
            .where('projectId', isEqualTo: id)
            .get();
        for (var updateDoc in updatesSnapshot.docs) {
          await _db.collection('updates').doc(updateDoc.id).delete();
        }

        print(
            'Project, image, related pledges, and updates deleted successfully');
      } else {
        print('Project not found');
      }
    } catch (e) {
      print('Error deleting project or related data: $e');
    }
  }

  Future<void> deleteProjectImage(String projectId) async {
    try {
      await _storage.ref('project_images/$projectId').delete();
      print('Project image deleted successfully');
    } catch (e) {
      print('Error deleting project image: $e');
    }
  }

  // New function to submit a project
  Future<void> submitProject(Project project) async {
    try {
      await _db
          .collection('projects')
          .doc(project.projectId)
          .set(project.toJson());
      print("Project added successfully");
    } catch (e) {
      print("Failed to add project: $e");
    }
  }

  // Pledge CRUD Operations
  Future<List<Pledge>> fetchPledges() async {
    var result = await _db.collection('pledges').get();
    return result.docs.map((doc) => Pledge.fromMap(doc.data())).toList();
  }

  Future<void> addPledge(Pledge pledge) async {
    await _db.collection('pledges').add(pledge.toJson());
  }

  Future<void> updatePledge(String id, Pledge pledge) async {
    await _db.collection('pledges').doc(id).update(pledge.toJson());
  }

  Future<void> deletePledge(String id) async {
    await _db.collection('pledges').doc(id).delete();
  }

  // Update CRUD Operations
  Future<List<Update>> fetchUpdates() async {
    var result = await _db.collection('updates').get();
    return result.docs.map((doc) => Update.fromMap(doc.data())).toList();
  }

  Future<void> addUpdate(Update update) async {
    await _db.collection('updates').add(update.toJson());
  }

  Future<void> updateUpdate(String id, Update update) async {
    await _db.collection('updates').doc(id).update(update.toJson());
  }

  Future<void> deleteUpdate(String id) async {
    await _db.collection('updates').doc(id).delete();
  }

  // User CRUD Operations
  Future<List<User>> fetchUsers() async {
    var result = await _db.collection('users').get();
    return result.docs.map((doc) {
      var user = User.fromJson(doc.data() as Map<String, dynamic>);
      return user.copyWith(userId: doc.id); // Set userId to document ID
    }).toList();
  }

  Future<void> addUser(User user) async {
    await _db.collection('users').add(user.toJson());
  }

  Future<void> updateUser(String id, User user) async {
    await _db.collection('users').doc(id).update(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    await _db.collection('users').doc(userId).delete();
    await deleteUserProfileImage(userId);
  }

  Future<void> deleteUserProfileImage(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    try {
      await _storage.ref('profile_pics/$userId').delete();
      print('User profile picture deleted successfully');
    } catch (e) {
      print('Error deleting user profile picture: $e');
    }
  }

  // Optionally, fetch a single user by ID
  Future<User?> fetchUserById(String userId) async {
    var doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<Project>> fetchPendingProjects() async {
    var result = await _db.collection('projects').get();
    return result.docs.map((doc) => Project.fromDocument(doc)).toList();
  }

  Future<void> updateProjectVerificationStatus(
      String projectId, String status) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .update({'verificationStatus': status});
  }

  Future<List<Project>> fetchVerifiedProjects() async {
    var result = await _db
        .collection('projects')
        .where('verificationStatus', isEqualTo: 'verified')
        .get();
    return result.docs.map((doc) => Project.fromMap(doc.data())).toList();
  }

  Future<void> updateProjectFund(String projectId, double amount) async {
    final projectRef = _db.collection('projects').doc(projectId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(projectRef);
      if (!snapshot.exists) {
        throw Exception("Project does not exist!");
      }
      final newFund = snapshot['currentFund'] + amount;
      transaction.update(projectRef, {'currentFund': newFund});
    });
  }

  Future<void> createPledge(Pledge pledge) async {
    try {
      final pledgeData = pledge.toJson();
      print('Pledge Data: $pledgeData');
      await _db.collection('pledges').add(pledgeData);
      print('Pledge created successfully');
    } catch (e) {
      print('Error creating pledge: $e');
    }
  }

  Future<List<Pledge>> fetchPledgesByUserId(String userId) async {
    var result = await _db
        .collection('pledges')
        .where('userId', isEqualTo: userId)
        .get();
    return result.docs.map((doc) => Pledge.fromMap(doc.data())).toList();
  }

  Future<void> addProjectToUserBackedProjects(
      String userId, String projectId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'backedProjects': FieldValue.arrayUnion([projectId])
    });
  }

  Future<Project> fetchProjectById(String projectId) async {
    var doc = await _db.collection('projects').doc(projectId).get();
    return Project.fromDocument(doc);
  }

  Future<void> addBackerToProject(String projectId, String userId) async {
    final projectRef = _db.collection('projects').doc(projectId);
    await projectRef.update({
      'backers': FieldValue.arrayUnion([userId])
    });
  }

  Future<List<Pledge>> fetchPledgesByProjectId(String projectId) async {
    var result = await _db
        .collection('pledges')
        .where('projectId', isEqualTo: projectId)
        .get();
    return result.docs.map((doc) => Pledge.fromMap(doc.data())).toList();
  }

  Future<List<Update>> fetchUpdatesByProjectId(String projectId) async {
    var result = await _db
        .collection('updates')
        .where('projectId', isEqualTo: projectId)
        .get();
    return result.docs.map((doc) => Update.fromMap(doc.data())).toList();
  }

  Future<String> fetchCreatorName(String creatorId) async {
    final doc = await _db.collection('users').doc(creatorId).get();
    return doc['username'];
  }
}
