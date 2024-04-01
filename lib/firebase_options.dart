// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOTr2miabgoWb8ukTDEfDI0gcyS21D3cw',
    appId: '1:802637922175:web:2712e4e3641b79874d644a',
    messagingSenderId: '802637922175',
    projectId: 'chattingapp-19906',
    authDomain: 'chattingapp-19906.firebaseapp.com',
    storageBucket: 'chattingapp-19906.appspot.com',
    measurementId: 'G-Q97774MXPM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4_KfeBtk4bXwwWWsxLYuwHESaBAVzmI0',
    appId: '1:802637922175:android:50f8d5bcc4f5a8354d644a',
    messagingSenderId: '802637922175',
    projectId: 'chattingapp-19906',
    storageBucket: 'chattingapp-19906.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1gER8WDRIMNWVPUkP8eXmOB6VDbh_xt8',
    appId: '1:802637922175:ios:458563bc75918adf4d644a',
    messagingSenderId: '802637922175',
    projectId: 'chattingapp-19906',
    storageBucket: 'chattingapp-19906.appspot.com',
    iosBundleId: 'com.bidbazaarChat.chatapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1gER8WDRIMNWVPUkP8eXmOB6VDbh_xt8',
    appId: '1:802637922175:ios:a74d599007415f764d644a',
    messagingSenderId: '802637922175',
    projectId: 'chattingapp-19906',
    storageBucket: 'chattingapp-19906.appspot.com',
    iosBundleId: 'com.bidbazaarChat.chatapp.RunnerTests',
  );
}