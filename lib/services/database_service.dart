import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/pledge.dart';
import '../models/fund_history.dart';
import '../models/update.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Project CRUD Operations
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
}
