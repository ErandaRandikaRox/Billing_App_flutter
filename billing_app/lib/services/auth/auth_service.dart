import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Get the instance of FirebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
    }
    // catch and error
    on FirebaseAuthException catch (e) {
      throw UserCredential;
    }
  }

  // Sign up
  Future<UserCredential> signUpwithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    }
    // catch and error
    on FirebaseAuthException catch (e) {
      throw UserCredential;
    }
  }

  // Log out
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
