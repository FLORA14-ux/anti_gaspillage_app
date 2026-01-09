import 'package:anti_gaspillage_app/screens/auth.dart';
import 'package:anti_gaspillage_app/screens/home.dart';
import 'package:anti_gaspillage_app/screens/merchant_home_screen.dart'; // Import MerchantHomeScreen
import 'package:anti_gaspillage_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti-Gaspillage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return RoleBasedScreen(userId: snapshot.data!.uid);
        }
        return const AuthScreen();
      },
    );
  }
}

class RoleBasedScreen extends StatelessWidget {
  final String userId;
  const RoleBasedScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (userSnapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Something went wrong.')));
        }
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final role = userData['role'];

          if (role == 'commercant') {
            return const MerchantHomeScreen(); // Merchant Screen
          } else {
            return const HomeScreen(); // Consumer Screen
          }
        }
        // This case might happen if the user document is not created yet
        // or was deleted. We send them back to the auth screen.
        return const AuthScreen();
      },
    );
  }
}