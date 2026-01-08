import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUp(String email, String password, String role) async {
    try {
      // 1. Firebase Auth crée l’utilisateur
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Tu écris dans Firestore : son rôle, son email
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'role': role,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs, par exemple, si l'email est déjà utilisé
      print(e.message);
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs
      print(e.message);
      return null;
    }
  }
}
