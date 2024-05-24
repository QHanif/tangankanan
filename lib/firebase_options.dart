// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpQO7oJpf0-zRfqEuGnalMkz1KDh7P-mo', // Updated Web API Key
    appId: '1:1006183749872:android:70c4de272f26a0e9bb0a35', // Updated App ID
    messagingSenderId: '1006183749872', // Updated project number
    projectId: 'tangankanan-app', // Updated project ID
    storageBucket:
        'tangankanan-app.appspot.com', // Update this if you have a new storage bucket
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpQO7oJpf0-zRfqEuGnalMkz1KDh7P-mo', // Updated Web API Key
    appId:
        '1:1006183749872:ios:70c4de272f26a0e9bb0a35', // Updated App ID for iOS
    messagingSenderId: '1006183749872', // Updated project number
    projectId: 'tangankanan-app', // Updated project ID
    storageBucket:
        'tangankanan-app.appspot.com', // Update this if you have a new storage bucket
    iosBundleId: 'com.example.tangankanan', // Updated package name
  );
}
