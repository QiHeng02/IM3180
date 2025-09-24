import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:im3180/widgets/bottom_nav.dart';
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
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
  );

  InputDecoration _decoration(String label, String hint) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B8190)),
    filled: true,
    fillColor: const Color(0xFFF7F8FC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: _fieldBorder,
    focusedBorder: _fieldBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false, // <-- Add this line
        appBar: AppBar(
          title: const Text('Change Password'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Old password
                  TextFormField(
                    controller: _oldCtrl,
                    obscureText: _hideOld,
                    decoration:
                        _decoration(
                          'Old Password',
                          'Enter your old password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideOld = !_hideOld),
                            icon: Icon(
                              _hideOld
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter your old password'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // New password
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: _hideNew,
                    decoration:
                        _decoration(
                          'New Password',
                          'Enter your new password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideNew = !_hideNew),
                            icon: Icon(
                              _hideNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                  const SizedBox(height: 16),

                  // Confirm password
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _hideConfirm,
                    decoration:
                        _decoration(
                          'Confirm New Password',
                          'Confirm your new password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            icon: Icon(
                              _hideConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                    validator: (v) =>
                        v != _newCtrl.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                              const SnackBar(
                                content: Text('Password updated successfully'),
                              ),
                            );

                            // Optionally clear fields or navigate away
                            _oldCtrl.clear();
                            _newCtrl.clear();
                            _confirmCtrl.clear();
                            Navigator.of(context).maybePop();
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.message ?? 'Failed to update password',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(currentIndex: 3),
      ),
    );
  }
}
