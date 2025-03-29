import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      log("User created successfully: ${cred.user?.uid}");
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Sign up failed: ${e.message}");
    } catch (e) {
      log("Unexpected error: $e");
    }
    return null;
  }



  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error logging in: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
