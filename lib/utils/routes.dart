// Import necessary packages and views
import 'package:flutter/material.dart';
import 'package:tangankanan/views/common/login_page.dart';
import 'package:tangankanan/views/common/register_page.dart';
import 'package:tangankanan/views/common/profile_page.dart';
import 'package:tangankanan/views/common/forgot_password_page.dart';
import 'package:tangankanan/views/common/update_profile_page.dart';
import 'package:tangankanan/views/backers/project_catalog_page.dart';
import 'package:tangankanan/views/backers/project_details_page.dart';
import 'package:tangankanan/views/backers/payment_page.dart';
import 'package:tangankanan/views/backers/project_top_backer_page.dart';
import 'package:tangankanan/views/backers/project_updates_page.dart';
import 'package:tangankanan/views/creators/creator_project_details_page.dart';
import 'package:tangankanan/views/creators/creator_project_page.dart';
import 'package:tangankanan/views/creators/create_project_page.dart';
import 'package:tangankanan/views/creators/community_updates_page.dart';
import 'package:tangankanan/views/creators/funding_progress_page.dart'; // Import the new page
import 'package:tangankanan/views/admin/admin_homepage.dart';
import 'package:tangankanan/app_root.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/views/admin/update_project_page.dart';

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
  '/adminHomepage': (context) => AdminHomePage(),
};

// Optionally, if you need to handle dynamic routes
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/creatorProjectDetails':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => CreatorProjectDetailsPage(project: project));
    case '/projectDetails':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => ProjectDetailsPage(project: project));
    case '/community_updates_page':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => CommunityUpdatesPage(project: project));
    case '/payment':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => PaymentPage(project: project));
    case '/projectTopBackers':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => ProjectTopBackerPage(project: project));
    case '/projectUpdates':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => ProjectUpdatesPage(project: project));
    case '/fundingProgress':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => FundingProgressPage(project: project));
    case '/updateProject':
      final project = settings.arguments as Project;
      return MaterialPageRoute(
          builder: (context) => UpdateProjectPage(project: project));
    default:
      return MaterialPageRoute(builder: (context) => AppRoot());
  }
}
