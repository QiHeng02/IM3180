import 'package:flutter/material.dart';

class ScanResultsScreen extends StatelessWidget {
  final double phValue;
  final String freshness;
  final int hoursToConsume;

  const ScanResultsScreen({
    Key? key,
    required this.phValue,
    required this.freshness,
    required this.hoursToConsume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Open drawer or menu
          },
        ),
        title: const Text(
          'Scan Results',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Results Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results Title
                        const Text(
                          'Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // pH Value Display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'pH ',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                            Text(
                              phValue.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // pH Scale Indicator
                        _buildPhScaleIndicator(context),

                        const SizedBox(height: 50),

                        // Freshness Status
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getFreshnessColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getFreshnessColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getFreshnessIcon(),
                                size: 40,
                                color: _getFreshnessColor(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getFreshnessMessage(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: _getFreshnessColor(),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Consumption Time
                        if (hoursToConsume > 0)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Consume within $hoursToConsume hours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Additional Info
                        const Spacer(),

                        // Tips Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F8FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 20,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Storage Tip',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getStorageTip(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Try Again Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 18,
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
    );
  }

  /// 修改后的方法，加入 BuildContext
  Widget _buildPhScaleIndicator(BuildContext context) {
    return Column(
      children: [
        // pH Scale Bar
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF0000), // Very acidic
                Color(0xFFFF6600), // Acidic
                Color(0xFFFFCC00), // Slightly acidic
                Color(0xFF66FF00), // Neutral/Fresh
                Color(0xFF00FF66), // Slightly alkaline
                Color(0xFF0066FF), // Alkaline
                Color(0xFF6600FF), // Very alkaline
              ],
            ),
          ),
          child: Stack(
            children: [
              // Position indicator
              Positioned(
                left: _calculateIndicatorPosition() *
                        (MediaQuery.of(context).size.width - 80) -
                    10,
                top: 5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getFreshnessColor(),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // pH Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('3.5', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('7', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('10.5', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('14', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  double _calculateIndicatorPosition() {
    // Normalize pH value (0-14) to position (0-1)
    return phValue / 14;
  }

  Color _getFreshnessColor() {
    switch (freshness) {
      case 'fresh':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'spoiled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getFreshnessIcon() {
    switch (freshness) {
      case 'fresh':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'spoiled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getFreshnessMessage() {
    switch (freshness) {
      case 'fresh':
        return 'This item is likely fresh';
      case 'moderate':
        return 'This item is moderately fresh';
      case 'spoiled':
        return 'This item may be spoiled';
      default:
        return 'Unable to determine freshness';
    }
  }

  String _getStorageTip() {
    switch (freshness) {
      case 'fresh':
        return 'Store in a cool, dry place. Keep refrigerated after opening to maintain freshness.';
      case 'moderate':
        return 'Consume soon. Store in refrigerator and use within the recommended time.';
      case 'spoiled':
        return 'Consider discarding this item. Check for any unusual smell or appearance before use.';
      default:
        return 'Follow standard storage guidelines for this product.';
    }
  }
}
