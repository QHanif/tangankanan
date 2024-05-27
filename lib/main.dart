import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:tangankanan/app_root.dart';
import 'utils/routes.dart'; // Make sure the path matches the location of your routes file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const AppRoot(), // whether use home or initialRoute. dont use both
      initialRoute: '/',
      routes: routes, // Use the routes defined in routes.dart
    );
  }
}
