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
            SnackBar(
              content: Row(
                children: [
                  const Text('❌', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to update settings: $e')),
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
    } else {
      debugPrint('No user logged in, cannot update notification settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !_enabled;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF7),
        appBar: AppBar(
          title: const Text(
            'Expiry Notifications',
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
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                )
              : Stack(
                  children: [
                    // Decorative icons
                    Positioned(
                      top: 5,
                      left: 8,
                      child: Text(
                        '🔔',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    
                    Positioned(
                      top: 5,
                      right: 8,
                      child: Text(
                        '⏰',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    
                    // Main content
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header section with icon
                          Container(
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
                                    Icons.notifications_active,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Stay Fresh!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Get notified before your food expires',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Enable notifications toggle
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8F5E9),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F8F4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Color(0xFF4CAF50),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Enable expiry notifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _enabled,
                                  onChanged: (val) async {
                                    setState(() => _enabled = val);
                                    await _saveSettings();
                                  },
                                  activeColor: const Color(0xFF4CAF50),
                                  activeTrackColor: const Color(0xFF66BB6A).withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Days before expiry section
                          Text(
                            'Days before expiry',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: disabled ? Colors.grey[100] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: disabled ? Colors.grey[300]! : const Color(0xFFE8F5E9),
                                width: 1.5,
                              ),
                              boxShadow: disabled ? [] : [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Minus button
                                Container(
                                  decoration: BoxDecoration(
                                    color: disabled || _daysBefore <= 1
                                        ? Colors.grey[200]
                                        : const Color(0xFFF1F8F4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: disabled || _daysBefore <= 1
                                          ? Colors.grey[300]!
                                          : const Color(0xFFE8F5E9),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: disabled || _daysBefore <= 1
                                        ? null
                                        : () => setState(() => _daysBefore--),
                                    icon: const Icon(Icons.remove),
                                    color: disabled || _daysBefore <= 1
                                        ? Colors.grey[400]
                                        : const Color(0xFF4CAF50),
                                    iconSize: 24,
                                  ),
                                ),

                                // Days display
                                Column(
                                  children: [
                                    Text(
                                      '$_daysBefore',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: disabled ? Colors.grey[400] : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      _daysBefore == 1 ? 'day' : 'days',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: disabled ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),

                                // Plus button
                                Container(
                                  decoration: BoxDecoration(
                                    color: disabled || _daysBefore >= 10
                                        ? Colors.grey[200]
                                        : const Color(0xFFF1F8F4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: disabled || _daysBefore >= 10
                                          ? Colors.grey[300]!
                                          : const Color(0xFFE8F5E9),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: disabled || _daysBefore >= 10
                                        ? null
                                        : () => setState(() => _daysBefore++),
                                    icon: const Icon(Icons.add),
                                    color: disabled || _daysBefore >= 10
                                        ? Colors.grey[400]
                                        : const Color(0xFF4CAF50),
                                    iconSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                const Text('💡', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    disabled
                                        ? 'Enable notifications to receive alerts'
                                        : 'You\'ll receive a notification $_daysBefore ${_daysBefore == 1 ? 'day' : 'days'} before your food expires',
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
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: disabled
                                  ? null
                                  : const LinearGradient(
                                      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                              color: disabled ? Colors.grey[300] : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: disabled ? [] : [
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
                                disabledBackgroundColor: Colors.transparent,
                                disabledForegroundColor: Colors.white70,
                              ),
                              onPressed: disabled
                                  ? null
                                  : () async {
                                      await _saveSettings();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Text('✅', style: TextStyle(fontSize: 20)),
                                              SizedBox(width: 12),
                                              Text('Settings saved successfully!'),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF4CAF50),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: disabled ? Colors.white70 : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: disabled ? Colors.white70 : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      ),
    );
  }
}