import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:im3180/screens/login_screen.dart';
import 'screens/tutorial1.dart';
import 'screens/tutorial2.dart';
import 'screens/tutorial3.dart';
import 'screens/tutorial4.dart';
import 'screens/home.dart';
import 'screens/register_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/expiry_notifications_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/1': (context) => const RegisterScreen(),
        '/tutorial1': (context) => const Tutorial1Screen(),
        '/tutorial2': (context) => const Tutorial2Screen(),
        '/tutorial3': (context) => const Tutorial3Screen(),
        '/tutorial4': (context) => const Tutorial4Screen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/expiry-notifications': (context) => const ExpiryNotificationsScreen(),
        '/a': (context) => const ChangePasswordScreen(),
        '/history': (context) => const HistoryScreen(),
        '/scan': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, String?>?;
          return ScanPage(
            selectedCategory: args?['selectedCategory'],
            selectedFood: args?['selectedFood'],
          );
        },
      },
    );
  }
}
