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
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool isLoading = false;
  String message = '';
  bool isError = false;

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        isError = true;
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
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.sendEmailVerification();

      setState(() {
        isError = false;
        message = 'Registered! Please verify your email.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isError = true;
        message = e.message ?? 'Registration error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4a90e2), Color(0xff145ca8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white.withOpacity(0.95),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Username',
                      icon: Icons.person_outline,
                      controller: usernameController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Confirm Password',
                      icon: Icons.lock_reset_outlined,
                      controller: confirmPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      controller: mobileController,
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back to Sign In',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                              : Text("Sign Up"),
                        ),
                      ],
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        message,
                        style: TextStyle(
                          color: isError ? Colors.red : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
