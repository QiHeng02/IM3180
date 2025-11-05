import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    debugPrint('Attempting login with email: $email');

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint('Login successful for email: $email');

      // Create Firestore user doc if not exists
      final user = userCredential.user;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'email': user.email, 'name': '', 'phone': ''});
        }
      }

      // Navigate to HomeScreen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/tutorial1');
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Login failed';
      debugPrint('Login failed for email: $email, Error: $message');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // Sign out any previous Google user to force account selection
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Create Firestore user doc if not exists
      final user = userCredential.user;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'email': user.email, 'name': '', 'phone': ''});
        }
      }

      // Navigate to Tutorial1Screen
      Navigator.pushReplacementNamed(context, '/tutorial1');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4E7C5),
              Color(0xFFE8F3DC),
              Color(0xFFF0F8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.eco,
                        size: 60,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // pHresh Title
                  const Text(
                    'pHresh',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F3F),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Nourish Your Journey
                  const Text(
                    'Nourish Your Journey',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5F3F),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black87),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Color(0xFF7CB342),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Color(0xFF7CB342),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remember Me
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFF7CB342);
                              }
                              return Colors.transparent;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7CB342),
                          Color(0xFF2D7D4A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF7CB342).withOpacity(0.4),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OR SIGN UP WITH
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR SIGN UP WITH',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Login Button
                  Center(
                    child: _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      color: Color(0xFF4285F4),
                      onTap: signInWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF7CB342),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/1');
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7CB342),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Color(0xFF7CB342),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Color(0xFF7CB342),
      ),
    );
  }
}