import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpPage.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  bool isLoading = false;

  void signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user!.emailVerified) {
        setState(() {
          message = 'Login successful!';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });

      } else {
        setState(() {
          message = 'Please verify your email before logging in.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? 'Login failed';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SignUpPage()));
                  },
                  child: Text("Sign Up"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Sign In"),
                ),
              ],
            ),

            // Message area
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
