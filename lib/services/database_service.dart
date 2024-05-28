import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/pledge.dart';
import '../models/fund_history.dart';
import '../models/update.dart';
import '../models/user.dart'; // Make sure to import the User model

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    await _db.collection('projects').doc(id).delete();
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
    return result.docs
        .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addUser(User user) async {
    await _db.collection('users').add(user.toJson());
  }

  Future<void> updateUser(String id, User user) async {
    await _db.collection('users').doc(id).update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
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
