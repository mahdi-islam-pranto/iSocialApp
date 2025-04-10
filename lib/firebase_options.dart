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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBprZPoI6pphdebzHQbPz4---9Bq8FwznA',
    appId: '1:42474504633:android:8b0844f2dc68de158bb668',
    messagingSenderId: '42474504633',
    projectId: 'isocial-98957',
    storageBucket: 'isocial-98957.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCd7j1rYDj7iEVwBJwd2agckksjTOTG-Zs',
    appId: '1:42474504633:ios:71d253473b79d25f8bb668',
    messagingSenderId: '42474504633',
    projectId: 'isocial-98957',
    storageBucket: 'isocial-98957.appspot.com',
    iosBundleId: 'com.example.ihelpbdCrm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCd7j1rYDj7iEVwBJwd2agckksjTOTG-Zs',
    appId: '1:42474504633:ios:71d253473b79d25f8bb668',
    messagingSenderId: '42474504633',
    projectId: 'isocial-98957',
    storageBucket: 'isocial-98957.appspot.com',
    iosBundleId: 'com.example.ihelpbdCrm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCeruB94SujrbUspoWvv8qe9qfY2zzHT3s',
    appId: '1:42474504633:web:d3617d77bbfca7f98bb668',
    messagingSenderId: '42474504633',
    projectId: 'isocial-98957',
    authDomain: 'isocial-98957.firebaseapp.com',
    storageBucket: 'isocial-98957.appspot.com',
    measurementId: 'G-KB34X6FJKC',
  );
}
