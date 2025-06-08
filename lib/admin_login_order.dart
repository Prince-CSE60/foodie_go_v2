import 'package:flutter/material.dart';
import 'admin_order.dart'; // Import your admin order page

class AdminLoginOrder extends StatefulWidget {
  const AdminLoginOrder({super.key});

  @override
  _AdminLoginOrderState createState() => _AdminLoginOrderState();
}

class _AdminLoginOrderState extends State<AdminLoginOrder> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final String _adminUsername = 'admin';
  final String _adminPassword = 'admin123';

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == _adminUsername && password == _adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminOrder()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid admin credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.deepOrange),
            SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Admin Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Admin Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _login,
              icon: Icon(Icons.login),
              label: Text('Login as Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
