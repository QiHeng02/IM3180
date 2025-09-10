import 'package:flutter/material.dart';

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: _fieldBorder,
        focusedBorder: _fieldBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
                  decoration: _decoration(
                    'Old Password',
                    'Enter your old password',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hideOld = !_hideOld),
                      icon: Icon(
                          _hideOld ? Icons.visibility_off : Icons.visibility),
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
                  decoration: _decoration(
                    'New Password',
                    'Enter your new password',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hideNew = !_hideNew),
                      icon: Icon(
                          _hideNew ? Icons.visibility_off : Icons.visibility),
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
                  decoration: _decoration(
                    'Confirm New Password',
                    'Confirm your new password',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => _hideConfirm = !_hideConfirm),
                      icon: Icon(_hideConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password saved')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel button
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
                    onPressed: () {
                      _oldCtrl.clear();
                      _newCtrl.clear();
                      _confirmCtrl.clear();
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2F6BFF),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Settings tab selected (0-based index)
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
           BottomNavigationBarItem(
             icon: Icon(Icons.play_lesson_outlined),
             activeIcon: Icon(Icons.play_lesson),
             label: 'Tutorial',
           ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // Handle navigation based on index
          switch (index) {
            case 0:
              // Navigate to Home
              Navigator.of(context).popUntil((route) => route.isFirst);
              break;
            case 1:
              // Navigate to Profile
              // Navigator.pushNamed(context, '/profile');
              break;
            case 2:
              // Navigate to Report
              // Navigator.pushNamed(context, '/report');
              break;
            case 3:
              // Already on Settings screen
              break;
          }
        },
      ),
    );
  }
}