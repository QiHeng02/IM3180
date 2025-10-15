import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Color(0xFFE8F5E9), width: 1.5),
  );

  InputDecoration _decoration(String label, String hint, IconData icon) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF66BB6A), size: 22),
    labelStyle: const TextStyle(
      fontSize: 14, 
      color: Color(0xFF4CAF50),
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle(
      fontSize: 13,
      color: Color(0xFFB0BEC5),
    ),
    filled: true,
    fillColor: const Color(0xFFF1F8F4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: _fieldBorder,
    focusedBorder: _fieldBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    errorBorder: _fieldBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
    ),
    focusedErrorBorder: _fieldBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFFDF7),
        appBar: AppBar(
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFDF7),
          foregroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: const Color(0xFF2E7D32),
          ),
          actions: const [LogoutButton()],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative elements - Top corners only
              Positioned(
                top: 5,
                left: 0,
                child: Text(
                  '🍃',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              
              Positioned(
                top: 5,
                right: 0,
                child: Text(
                  '🍊',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              
              // Bottom corners - above nav bar
              Positioned(
                bottom: 300,
                left: 8,
                child: Text(
                  '🥕',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              
              Positioned(
                bottom: 300,
                right: 4,
                child: Text(
                  '🍉',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              
              // Main content
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative header section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Secure Your Account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🥗 Keep your PHresh account safe 🥗',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Old password
                      TextFormField(
                        controller: _oldCtrl,
                        obscureText: _hideOld,
                        decoration:
                            _decoration(
                              'Current Password',
                              'Enter your current password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hideOld = !_hideOld),
                                icon: Icon(
                                  _hideOld
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF66BB6A),
                                ),
                              ),
                            ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter your current password'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // New password
                      TextFormField(
                        controller: _newCtrl,
                        obscureText: _hideNew,
                        decoration:
                            _decoration(
                              'New Password',
                              'Enter your new password',
                              Icons.vpn_key_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hideNew = !_hideNew),
                                icon: Icon(
                                  _hideNew
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF66BB6A),
                                ),
                              ),
                            ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (v.length < 8) {
                            return 'Must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm password
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _hideConfirm,
                        decoration:
                            _decoration(
                              'Confirm Password',
                              'Re-enter your new password',
                              Icons.check_circle_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hideConfirm = !_hideConfirm),
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF66BB6A),
                                ),
                              ),
                            ),
                        validator: (v) =>
                            v != _newCtrl.text ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 12),

                      // Password requirements hint
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE8F5E9),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password must be at least 8 characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                final credential = EmailAuthProvider.credential(
                                  email: user!.email!,
                                  password: _oldCtrl.text,
                                );

                                // Re-authenticate
                                await user.reauthenticateWithCredential(credential);

                                // Update password
                                await user.updatePassword(_newCtrl.text);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Text('✅', style: TextStyle(fontSize: 20)),
                                        SizedBox(width: 12),
                                        Text('Password updated successfully!'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );

                                // Clear fields and navigate away
                                _oldCtrl.clear();
                                _newCtrl.clear();
                                _confirmCtrl.clear();
                                Navigator.of(context).maybePop();
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Text('❌', style: TextStyle(fontSize: 20)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            e.message ?? 'Failed to update password',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF5350),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(currentIndex: 3),
      ),
    );
  }
}