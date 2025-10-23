import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFFFFDF7),
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
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
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
            future: _getUserDoc(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                );
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  !snapshot.data!.exists) {
                return const Center(child: Text('No user data found'));
              }
              final data = snapshot.data!.data()!;
              _nameController.text = data['name'] ?? '';
              _emailController.text = data['email'] ?? '';
              _phoneController.text = data['phone'] ?? '';
              
              return Stack(
                children: [
                  // Decorative food icons - corners only
                  Positioned(
                    top: 5,
                    left: 8,
                    child: Text(
                      '🥗',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  
                  Positioned(
                    top: 5,
                    right: 8,
                    child: Text(
                      '🍎',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 100,
                    left: 8,
                    child: Text(
                      '🥑',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 100,
                    right: 8,
                    child: Text(
                      '🍇',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  
                  // Main content
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        
                        // Profile Avatar Section
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative circle background
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF66BB6A).withOpacity(0.2),
                                      Color(0xFF4CAF50).withOpacity(0.2),
                                    ],
                                  ),
                                ),
                              ),
                              // Avatar
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE8F5E9),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF66BB6A),
                                ),
                              ),
                              // Camera button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                                    ),
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Name field
                        TextField(
                          controller: _nameController,
                          decoration: _decoration(
                            'Full Name',
                            'Enter your name',
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field
                        TextField(
                          controller: _emailController,
                          enabled: false,
                          decoration: _decoration(
                            'Email',
                            'Your email address',
                            Icons.email_outlined,
                          ).copyWith(
                            fillColor: const Color(0xFFE8F5E9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone field
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: _decoration(
                            'Phone',
                            'Enter your phone number',
                            Icons.phone_outlined,
                          ).copyWith(
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Info hint
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
                              const Text('ℹ️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Phone number must be 8 digits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Save button
                        Container(
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
                              final phone = _phoneController.text.trim();
                              if (phone.length != 8 || int.tryParse(phone) == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Text('⚠️', style: TextStyle(fontSize: 20)),
                                        SizedBox(width: 12),
                                        Text('Invalid phone number'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF5350),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                      'name': _nameController.text,
                                      'phone': phone,
                                      'email': user.email,
                                    }, SetOptions(merge: true));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Text('✅', style: TextStyle(fontSize: 20)),
                                        SizedBox(width: 12),
                                        Text('Profile updated successfully!'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                setState(() {}); // Refresh data after save
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check_circle, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      ),
    );
  }
}