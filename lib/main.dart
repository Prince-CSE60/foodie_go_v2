import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SignInPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDsi_s2_tOXqLp5Z85F07zgHC1W7XJuKRI",
          authDomain: "foodie-go-52b46.firebaseapp.com",
          projectId: "foodie-go-52b46",
          storageBucket: "foodie-go-52b46.firebasestorage.app",
          messagingSenderId: "571709234687",
          appId: "1:571709234687:web:905e9da682d5b7470b5bca",
          measurementId: "G-24F7JF99SH",
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
