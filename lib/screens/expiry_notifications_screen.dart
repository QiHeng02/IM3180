import 'package:flutter/material.dart';

class ExpiryNotificationsScreen extends StatefulWidget {
  const ExpiryNotificationsScreen({super.key});

  @override
  State<ExpiryNotificationsScreen> createState() =>
      _ExpiryNotificationsScreenState();
}

class _ExpiryNotificationsScreenState extends State<ExpiryNotificationsScreen> {
  bool _enabled = true;
  int _daysBefore = 3; // allowed range: 1..30
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  // Styles to match your Change Password screen
  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
      );

  BoxDecoration get _tileDecoration => BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      );

  TextStyle get _labelStyle =>
      const TextStyle(fontSize: 12, color: Color(0xFF7B8190));

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Select Notification Time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              helpTextStyle: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$mm $period';
  }

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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 20),

              // Enable toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: _tileDecoration,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enable notifications',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Get alerts before items expire',
                            style: _labelStyle,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Days before expiry (stepper)
              Opacity(
                opacity: disabled ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: disabled,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: _tileDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Days before expiry',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'Choose how many days in advance to notify',
                          style: _labelStyle,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _RoundIconButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_daysBefore > 1) {
                                  setState(() => _daysBefore--);
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE6E8EF)),
                              ),
                              child: Text(
                                '$_daysBefore day${_daysBefore == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _RoundIconButton(
                              icon: Icons.add,
                              onTap: () {
                                if (_daysBefore < 30) {
                                  setState(() => _daysBefore++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Time of day picker
              const SizedBox(height: 28),

              // Save button
              SizedBox(
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
                    // TODO: Wire to backend / local persistence
                    final msg = _enabled
                        ? 'Saved • $_daysBefore day(s) before'
                        : 'Saved • Notifications disabled';
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  },
                  child: const Text('Save Settings'),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button
              SizedBox(
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
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
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
              // Navigate to Tutorial
              // Navigator.pushNamed(context, '/tutorial');
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

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
