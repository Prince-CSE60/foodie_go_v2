import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SignInPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBwAIZC3zh00cWaERgfLhUrKzM8491PwI0",
        authDomain: "foodiego-f7bbd.firebaseapp.com",
        projectId: "foodiego-f7bbd",
        storageBucket: "foodiego-f7bbd.firebasestorage.app",
        messagingSenderId: "313525126911",
        appId: "1:313525126911:web:9c388d57ad198c198baeca",
        measurementId: "G-B7LEE2VF3V",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      home: SignInPage(), // start with login
    );
  }
}
