import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutorial2Screen extends StatelessWidget {
  const Tutorial2Screen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'onboardingDone': true,
      }, SetOptions(merge: true));
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tutorial',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/Tutorial step 2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  const Text(
                    'Step 2: Results',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "pH value, freshness level and hours to be consumed by will be shown.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Continue → mark done, then go Home
                  onPressed: () => _completeOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue to app',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
