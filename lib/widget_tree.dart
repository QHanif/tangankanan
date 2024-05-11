import 'package:flutter/material.dart';
import 'package:tangankanan/auth.dart';
import 'package:tangankanan/pages/login_page.dart';
import 'package:tangankanan/pages/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        print('StreamBuilder rebuilt with data: ${snapshot.data}');
        if (snapshot.hasData) {
          return HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
