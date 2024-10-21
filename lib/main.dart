import 'package:entrylevel_app/registation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'forget_pass.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // This will be changed based on user state
    );
  }
}

// This class will handle the user authentication state
class AuthService {
  static bool isLoggedIn = false; // This flag indicates whether the user is logged in
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('https://reqres.in/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Set user as logged in
      AuthService.isLoggedIn = true;
      // Navigate to Home Page on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Redirect to Home Page if already logged in
    if (AuthService.isLoggedIn) {
      return HomePage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login.png'), // Path to the local image
                  fit: BoxFit.cover, // Adjust how the image fits the container
                ),
              ),
            ),
            const SizedBox(height: 20,),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.all(16.0)),
                Text('Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email ID',
                      prefixIcon: Icon(Icons.alternate_email), // Add icon before TextField
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.remove_red_eye_outlined : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText, // Control whether text is obscured or not
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: _login,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('OR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),),
                  const SizedBox(height: 20,),
                  GestureDetector(
                    // Placeholder function for Google login
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google.png', height: 50, width: 50,),
                          const SizedBox(width: 10),
                          const Text(
                            'Login with Google',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to Logistics? ",
                        style: TextStyle(color: Colors.black), // Adjust color and style if needed
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}