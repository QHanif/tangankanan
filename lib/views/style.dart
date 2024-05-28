import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFD8ECFF); // Example primary color
  static const Color secondary = Color(0xFF1E88E5); // Example secondary color

  static const Color primaryButton =
      Color(0xFF143CC9); // Example primary button color
  static const Color text = Color(0xFF000000); // Example text color
  static const Color error = Color(0xFFD32F2F); // Example error color
  static const Color textFieldBorder =
      Color.fromARGB(255, 72, 75, 233); // Example text field border color
  static const Color secondaryButton =
      Color(0xFF1E88E5); // Example secondary button color
}

class AppStyles {
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryButton,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(vertical: 16.0),
  );

  static Widget button(String text, VoidCallback action) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }

  static Widget buttonWithIcon(
      String text, IconData icon, VoidCallback action) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            SizedBox(width: 8.0),
            Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      color: Colors.white,
      // gradient: LinearGradient(
      //   colors: [Color.fromARGB(0, 168, 187, 255), Colors.white],
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      // ),
    );
  }
}
