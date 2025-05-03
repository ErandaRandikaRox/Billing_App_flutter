import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Get the instance of FirebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Get the instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign in
  Future<UserCredential> signInwithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Throw the actual FirebaseAuthException instead of UserCredential
      throw Exception('Sign-in failed: ${e.message}');
    }
  }

  // Sign up
  Future<UserCredential> signUpwithEmailPassword(
    String email,
    String password,
    String username, // Add username parameter
  ) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store username in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Throw the actual FirebaseAuthException instead of UserCredential
      throw Exception('Sign-up failed: ${e.message}');
    }
  }

  // Log out
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}