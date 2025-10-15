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
  bool _rememberMe = true; // Default to true as shown in image
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    }
  }

  Future<void> signup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

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

      // After signup, navigate to HomeScreen
      Navigator.pushReplacementNamed(context, '/tutorial1');
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Signup failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8), // Light green
              Color(0xFFD4F1D4), // Slightly darker green
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // pHresh Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'pHresh',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.eco, color: Colors.green[600], size: 20),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Login / Register text
                      Text(
                        'Login / Register',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'example@email.com',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
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

                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.green[600],
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Login Button with gradient
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF39C05B), Color(0xFF39C05B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // OR SIGN UP WITH text
                      const Center(
                        child: Text(
                          'OR SIGN UP WITH',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Social Login Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(
                            'G',
                            const Color(0xFFDB4437),
                            () => signInWithGoogle(),
                          ),
                          const SizedBox(width: 20),
                          _buildSocialIcon(
                            'f',
                            const Color(0xFF4267B2),
                            () => _handleFacebookLogin(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Register Button with gradient
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/1');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    String text,
    Color color,
    VoidCallback onTap, {
    bool isApple = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isApple
              ? CustomPaint(
                  size: const Size(20, 20),
                  painter: AppleLogoPainter(),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleFacebookLogin() {
    _showSnackBar('Facebook login clicked');
  }

  void _handleAppleLogin() {
    _showSnackBar('Apple login clicked');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class AppleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;

    // Main apple body
    final applePath = Path();
    applePath.moveTo(size.width * 0.5, size.height * 0.05);

    // Left side of apple
    applePath.cubicTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.05,
      size.height * 0.25,
      size.width * 0.05,
      size.height * 0.5,
    );
    applePath.cubicTo(
      size.width * 0.05,
      size.height * 0.75,
      size.width * 0.25,
      size.height * 0.95,
      size.width * 0.5,
      size.height * 0.95,
    );

    // Right side of apple
    applePath.cubicTo(
      size.width * 0.75,
      size.height * 0.95,
      size.width * 0.95,
      size.height * 0.75,
      size.width * 0.95,
      size.height * 0.5,
    );
    applePath.cubicTo(
      size.width * 0.95,
      size.height * 0.25,
      size.width * 0.75,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.05,
    );

    // Bite mark (cutout)
    final bitePath = Path();
    bitePath.moveTo(size.width * 0.65, size.height * 0.25);
    bitePath.cubicTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.35,
      size.width * 0.8,
      size.height * 0.4,
    );
    bitePath.cubicTo(
      size.width * 0.8,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.55,
    );
    bitePath.cubicTo(
      size.width * 0.65,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.45,
      size.width * 0.6,
      size.height * 0.4,
    );
    bitePath.cubicTo(
      size.width * 0.6,
      size.height * 0.35,
      size.width * 0.62,
      size.height * 0.3,
      size.width * 0.65,
      size.height * 0.25,
    );

    // Leaf
    final leafPath = Path();
    leafPath.moveTo(size.width * 0.5, size.height * 0.05);
    leafPath.cubicTo(
      size.width * 0.6,
      size.height * 0.0,
      size.width * 0.7,
      size.height * 0.05,
      size.width * 0.65,
      size.height * 0.15,
    );
    leafPath.cubicTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.55,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.05,
    );

    // Draw apple body
    canvas.drawPath(applePath, paint);

    // Draw leaf
    canvas.drawPath(leafPath, paint);

    // Draw bite mark by cutting it out
    canvas.drawPath(
      bitePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
