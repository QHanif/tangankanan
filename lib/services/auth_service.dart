import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required String role,
    required DateTime? birthdate,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    if (user != null) {
      // Add additional user details to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role,
        'createdProjects': role == 'creator' ? [] : null,
        'backedProjects': role == 'backer' ? [] : null,
        'registerDate': DateTime.now().toIso8601String(),
        'birthdate': birthdate?.toIso8601String(),
        'profilePictureUrl': await _storage
            .ref('public/default_profile_pic.jpg')
            .getDownloadURL(),
      });
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      } else {
        print('No user is currently signed in or user ID does not match.');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
