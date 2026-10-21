import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatApp',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF128C7E),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF075E54),
          foregroundColor: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
        return linux;
      case TargetPlatform.web:
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-web-key',
    appId: '1:000000000000:web:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    authDomain: 'demo-project.firebaseapp.com',
    storageBucket: 'demo-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-android-key',
    appId: '1:000000000000:android:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-ios-key',
    appId: '1:000000000000:ios:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
    iosBundleId: 'com.example.chatapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-macos-key',
    appId: '1:000000000000:macos:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
    iosBundleId: 'com.example.chatapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo-windows-key',
    appId: '1:000000000000:windows:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'demo-linux-key',
    appId: '1:000000000000:linux:demo',
    messagingSenderId: '000000000000',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
  );
}
