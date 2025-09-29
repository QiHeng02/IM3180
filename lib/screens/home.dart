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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // <-- Add this line
        title: const Text(
          'Home page',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: const [LogoutButton()],
      ),
      //create dropdown menu from firestore collection "categories"
      body: StreamBuilder<QuerySnapshot>(
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

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text('Category', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text('Select a category'),
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
                const SizedBox(height: 24),
                const Text('Food Item', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text('Select a food item'),
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
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7CFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex),
    );
  }
}
