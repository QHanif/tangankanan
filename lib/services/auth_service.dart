import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    required DateTime? birthdate, // Added parameter
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    if (user != null) {
      // Add additional user details to Firestore
      await _firestore.collection('Users').doc(user.uid).set({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role,
        'createdProjects': role == 'creator' ? [] : null,
        'backedProjects': role == 'backer' ? [] : null,
        'registerDate': DateTime.now().toIso8601String(),
        'birthdate': birthdate?.toIso8601String(), // Store birthdate
        'profilePictureUrl':
            null // Assuming you will set this later or modify to include as a parameter
      });
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
