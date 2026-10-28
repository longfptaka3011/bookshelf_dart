import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android configuration from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2PgfwsmyhRjONMQwQGbuAC54ndSzE13Y',
    appId: '1:818570529847:android:220db22e8180d8f33983b2',
    messagingSenderId: '818570529847',
    projectId: 'bookshelf-prm393-6a65c',
    storageBucket: 'bookshelf-prm393-6a65c.firebasestorage.app',
  );

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2PgfwsmyhRjONMQwQGbuAC54ndSzE13Y',
    appId: '1:818570529847:web:220db22e8180d8f33983b2',
    messagingSenderId: '818570529847',
    projectId: 'bookshelf-prm393-6a65c',
    authDomain: 'bookshelf-prm393-6a65c.firebaseapp.com',
    storageBucket: 'bookshelf-prm393-6a65c.firebasestorage.app',
  );

  // iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2PgfwsmyhRjONMQwQGbuAC54ndSzE13Y',
    appId: '1:818570529847:ios:220db22e8180d8f33983b2',
    messagingSenderId: '818570529847',
    projectId: 'bookshelf-prm393-6a65c',
    storageBucket: 'bookshelf-prm393-6a65c.firebasestorage.app',
    iosBundleId: 'com.example.bookshelf',
  );
}
