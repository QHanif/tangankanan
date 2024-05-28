import 'package:flutter/material.dart';
import 'package:tangankanan/views/admin/admin_homepage.dart';
import 'package:tangankanan/views/backers/project_catalog_page.dart';
import 'package:tangankanan/views/common/login_page.dart';
// import 'package:tangankanan/views/common/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tangankanan/views/creators/creator_project_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Fetch the role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.done) {
                if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                  var data = roleSnapshot.data!.data()
                      as Map<String, dynamic>; // Cast to Map
                  if (data.containsKey('role')) {
                    // Redirect based on the role
                    switch (data['role']) {
                      case 'creator':
                        return const CreatorProjectPage();
                      case 'backer':
                        return const ProjectCatalogPage();
                      case 'admin':
                        return const AdminHomePage();
                      default:
                        return const LoginPage(); // Default to login page if role is not recognized
                    }
                  } else {
                    // Return LoginPage if 'role' key is missing
                    return const LoginPage();
                  }
                } else {
                  // Return LoginPage if there's no data
                  return const LoginPage();
                }
              } else {
                // Show loading indicator while fetching role
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
