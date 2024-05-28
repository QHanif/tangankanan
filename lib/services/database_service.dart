import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/pledge.dart';
import '../models/fund_history.dart';
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

        print('Project and image deleted successfully');
      } else {
        print('Project not found');
      }
    } catch (e) {
      print('Error deleting project or image: $e');
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

  // FundHistory CRUD Operations
  Future<List<FundHistory>> fetchFundHistories() async {
    var result = await _db.collection('fund_histories').get();
    return result.docs.map((doc) => FundHistory.fromMap(doc.data())).toList();
  }

  Future<void> addFundHistory(FundHistory fundHistory) async {
    await _db.collection('fund_histories').add(fundHistory.toJson());
  }

  Future<void> updateFundHistory(String id, FundHistory fundHistory) async {
    await _db.collection('fund_histories').doc(id).update(fundHistory.toJson());
  }

  Future<void> deleteFundHistory(String id) async {
    await _db.collection('fund_histories').doc(id).delete();
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
}
