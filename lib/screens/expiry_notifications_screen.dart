import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';

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
        automaticallyImplyLeading: true, // Show back arrow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      onChanged: (val) => setState(() => _enabled = val),
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
                      onTap: disabled || _daysBefore >= 30
                          ? null
                          : () => setState(() => _daysBefore++),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notification time picker
              Text('Notification time', style: _labelStyle),
              Container(
                decoration: _tileDecoration,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF2F6BFF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatTimeOfDay(_time),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: disabled ? null : _pickTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: disabled
                      ? null
                      : () {
                          // TODO: Save notification settings to backend
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved!')),
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
