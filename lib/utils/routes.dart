// Import necessary packages and views
import 'package:flutter/material.dart';
import 'package:tangankanan/views/common/login_page.dart';
import 'package:tangankanan/views/common/register_page.dart';
import 'package:tangankanan/views/common/profile_page.dart';
import 'package:tangankanan/views/common/forgot_password_page.dart';
import 'package:tangankanan/views/common/update_profile_page.dart';
import 'package:tangankanan/views/backers/project_catalog_page.dart';
import 'package:tangankanan/views/creators/creator_project_details_page.dart';
import 'package:tangankanan/views/creators/creator_project_page.dart';
import 'package:tangankanan/views/creators/create_project_page.dart';
import 'package:tangankanan/views/creators/community_updates_page.dart'; // Import the new page
import 'package:tangankanan/views/admin/admin_project_catalog_page.dart';
import 'package:tangankanan/app_root.dart';
import 'package:tangankanan/models/project.dart';

// Define the routes
final Map<String, WidgetBuilder> routes = {
  '/': (context) => AppRoot(),
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/profile': (context) => ProfilePage(),
  '/forgotPassword': (context) => ForgotPasswordPage(),
  '/updateProfile': (context) => UpdateProfilePage(),
  '/projectCatalog': (context) => ProjectCatalogPage(),
  '/creatorProjects': (context) => CreatorProjectPage(),
  '/createProject': (context) => CreateProjectPage(),
  '/adminCatalog': (context) => AdminProjectCatalogPage(),
};

// Optionally, if you need to handle dynamic routes
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/creatorProjectDetails':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => CreatorProjectDetailsPage(project: project));
    case '/community_updates_page': // Add the new route
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => CommunityUpdatesPage(project: project));
    default:
      return MaterialPageRoute(builder: (context) => AppRoot());
  }
}
