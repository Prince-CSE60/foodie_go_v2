import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool isLoading = false;
  String message = '';

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        message = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await userCredential.user!.sendEmailVerification();

      setState(() {
        message = 'Registered! Please verify your email.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? 'Registration error';
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
      appBar: AppBar(title: Text("Sign Up"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Input Fields
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // back to sign-in
                    },
                    child: Text("Sign In"),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Sign Up"),
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
      ),
    );
  }
}
