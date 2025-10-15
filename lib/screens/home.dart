import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:im3180/widgets/bottom_nav.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.red),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User successfully logged out')),
            );
            Navigator.pushReplacementNamed(context, '/');
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User still logged in: \\${user.email}')),
            );
          }
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _ensureUserSelectionFields();
  }

  Future<void> _ensureUserSelectionFields() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data == null ||
          !data.containsKey('selectedCategory') ||
          !data.containsKey('selectedFood')) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'selectedCategory': null,
          'selectedFood': null,
        }, SetOptions(merge: true));
      }
    }
  }

  int _selectedIndex = 0;
  String? selectedCategory;
  String? selectedFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // pHresh Logo
                  Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pHresh',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  // Logout Button
                  const LogoutButton(),
                ],
              ),
            ),
            
            // Home page text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  'Home page',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Input Fields Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("categories").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var categories = snapshot.data!.docs;
                  var categoryNames = categories.map((doc) => doc.id).toList();
                  var foodItems = selectedCategory != null
                      ? List<String>.from(
                          categories.firstWhere(
                            (doc) => doc.id == selectedCategory,
                          )["items"],
                        )
                      : <String>[];

                  return Column(
                    children: [
                      // Category Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.checklist,
                                color: Colors.red[600],
                                size: 20,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            hint: const Text('Category'),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          value: selectedCategory,
                          items: categoryNames
                              .map(
                                (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              selectedFood = null;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Food Item Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.red[600],
                                size: 20,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            hint: const Text('Food Item'),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          value: selectedFood,
                          items: foodItems
                              .map(
                                (food) =>
                                    DropdownMenuItem(value: food, child: Text(food)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFood = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF39C05B),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39C05B).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39C05B),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  if (selectedCategory == null || selectedFood == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select both category and food item.',
                        ),
                      ),
                    );
                    return;
                  }
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not logged in!')),
                    );
                    return;
                  }
                  // Store selection in users collection
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set({
                        'selectedCategory': selectedCategory,
                        'selectedFood': selectedFood,
                      }, SetOptions(merge: true));
                  debugPrint(
                    'Stored for user ${user.uid}: category=${selectedCategory ?? "None"}, food=${selectedFood ?? "None"}',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved! Category: ${selectedCategory ?? "None"}, Food: ${selectedFood ?? "None"}',
                      ),
                    ),
                  );
                  //Navigator.pushReplacementNamed(context, '/scan');
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bottom Illustration Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/homepg.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Homepage image not found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex),
    );
  }
}