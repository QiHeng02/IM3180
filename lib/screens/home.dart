import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4A7CFF)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // Debug message and SnackBar
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                print('✅ User is logged out');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User successfully logged out'),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/');
                }
              } else {
                print('❌ User is still logged in: ${user.email}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User still logged in: ${user.email}'),
                    ),
                  );
                }
              }
            },
          ),
        ],
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
                      onPressed: () {
                        // TODO: Handle submit
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
