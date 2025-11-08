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
              SnackBar(content: Text('User still logged in: ${user.email}')),
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

  bool get _canScan => selectedCategory != null && selectedFood != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Colors.green[600], size: 28),
            const SizedBox(width: 8),
            Text(
              'phresh',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: const [
          LogoutButton(), // use the same logout button as other screens
        ],
      ),
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section with Image
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cultivate Your Plate.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Discover Peak Freshness',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Scan Button
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: GestureDetector(
                    onTap: () {
                      if (_canScan) {
                        Navigator.pushReplacementNamed(context, '/scan');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Select a category and a food item first',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _canScan ? Colors.green[500] : Colors.grey[400],
                        boxShadow: [
                          BoxShadow(
                            color: (_canScan ? Colors.green : Colors.grey)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Scan Now &',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Uncover!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category and Food Item Buttons
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showCategoryDialog(context, categoryNames);
                            },
                            icon: Icon(Icons.list, color: Colors.green[600]),
                            label: Text(
                              selectedCategory ?? 'Category',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Colors.green[600]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: selectedCategory == null
                                ? null
                                : () {
                                    _showFoodItemDialog(context, foodItems);
                                  },
                            icon: Icon(
                              Icons.restaurant,
                              color: selectedCategory == null
                                  ? Colors.grey
                                  : Colors.green[600],
                            ),
                            label: Text(
                              selectedFood ?? 'Food Item',
                              style: TextStyle(
                                color: selectedCategory == null
                                    ? Colors.grey
                                    : Colors.green[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: selectedCategory == null
                                    ? Colors.grey
                                    : Colors.green[600]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Freshness Hub Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Freshness Hub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400), // Limit width for centering
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: 32,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Fact of the day:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If you pick up the tofu and it feels slimy, greasy, or mushy (beyond its original firmness), it is a sign of bacterial growth and should be discarded.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex),
    );
  }

  void _showCategoryDialog(BuildContext context, List<String> categories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              return ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() {
                    selectedCategory = cat;
                    selectedFood = null;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFoodItemDialog(BuildContext context, List<String> foodItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Food Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: foodItems.map((food) {
              return ListTile(
                title: Text(food),
                onTap: () async {
                  setState(() {
                    selectedFood = food;
                  });
                  Navigator.pop(context);

                  // Save to Firestore
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                          'selectedCategory': selectedCategory,
                          'selectedFood': selectedFood,
                        }, SetOptions(merge: true));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saved! Category: $selectedCategory, Food: $selectedFood',
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
