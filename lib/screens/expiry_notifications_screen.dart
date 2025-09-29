import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpiryNotificationsScreen extends StatefulWidget {
  const ExpiryNotificationsScreen({super.key});

  @override
  State<ExpiryNotificationsScreen> createState() =>
      _ExpiryNotificationsScreenState();
}

class _ExpiryNotificationsScreenState extends State<ExpiryNotificationsScreen> {
  bool _enabled = false;
  int _daysBefore = 10; // allowed range: 1..10
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['notificationSettings'] != null) {
        final settings = data['notificationSettings'];
        _enabled = settings['enabled'] ?? false;
        final loadedDays = settings['daysBefore'];
        _daysBefore = (loadedDays is int && loadedDays >= 1 && loadedDays <= 10)
            ? loadedDays
            : 10;
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'notificationSettings': {
            'enabled': _enabled,
            'daysBefore': _enabled ? _daysBefore : null,
          },
        }, SetOptions(merge: true));
        debugPrint(
          'Notification settings updated: enabled=$_enabled, daysBefore=${_enabled ? _daysBefore : null}',
        );
      } catch (e) {
        debugPrint('Failed to update notification settings: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update settings: $e')),
          );
        }
      }
    } else {
      debugPrint('No user logged in, cannot update notification settings');
    }
  }

  BoxDecoration get _tileDecoration => BoxDecoration(
    color: const Color(0xFFF7F8FC),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFE6E8EF)),
  );

  TextStyle get _labelStyle =>
      const TextStyle(fontSize: 12, color: Color(0xFF7B8190));

  @override
  Widget build(BuildContext context) {
    final disabled = !_enabled;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Expiry Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        automaticallyImplyLeading: true, // Show back arrow
        actions: const [LogoutButton()],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    // Enable/disable notifications
                    Container(
                      decoration: _tileDecoration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF2F6BFF),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enable expiry notifications',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Switch(
                            value: _enabled,
                            onChanged: (val) async {
                              setState(() => _enabled = val);
                              await _saveSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Days before expiry
                    Text('Days before expiry', style: _labelStyle),
                    Container(
                      decoration: _tileDecoration,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.remove,
                            onTap: disabled || _daysBefore <= 1
                                ? null
                                : () => setState(() => _daysBefore--),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$_daysBefore days',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                          _RoundIconButton(
                            icon: Icons.add,
                            onTap: disabled || _daysBefore >= 10
                                ? null
                                : () => setState(() => _daysBefore++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 32),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: disabled
                            ? null
                            : () async {
                                await _saveSettings();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Settings saved!'),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6E8EF)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
}
