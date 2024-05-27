// Import necessary packages and views
import 'package:flutter/material.dart';
import 'package:tangankanan/views/common/login_page.dart';
import 'package:tangankanan/views/common/register_page.dart';
import 'package:tangankanan/views/common/profile_page.dart';
import 'package:tangankanan/views/common/forgot_password_page.dart';
import 'package:tangankanan/views/common/update_profile_page.dart';
import 'package:tangankanan/views/backers/project_catalog_page.dart';
// import 'package:tangankanan/views/backers/project_details_page.dart';
import 'package:tangankanan/views/creators/creator_project_page.dart';
import 'package:tangankanan/views/creators/create_project_page.dart'; // Import CreateProjectPage
import 'package:tangankanan/views/admin/admin_project_catalog_page.dart';
import 'package:tangankanan/app_root.dart'; // Import the WidgetTree class

// Define the routes
final Map<String, WidgetBuilder> routes = {
  '/': (context) => AppRoot(), // Root route
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/profile': (context) => ProfilePage(),
  '/forgotPassword': (context) => ForgotPasswordPage(),
  '/updateProfile': (context) => UpdateProfilePage(),
  '/projectCatalog': (context) => ProjectCatalogPage(),
  // '/projectDetails': (context) => ProjectDetailsPage(),
  '/creatorProjects': (context) => CreatorProjectPage(),
  '/createProject': (context) =>
      CreateProjectPage(), // Add CreateProjectPage route
  '/adminCatalog': (context) => AdminProjectCatalogPage(),
  // '/home': (context) => AppRoot(), // Remove this line
  // Add other routes here
};
