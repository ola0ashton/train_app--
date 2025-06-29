// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Create a singleton instance
  static final AuthService _instance = AuthService._internal();
  
  // Factory constructor to return the same instance each time
  factory AuthService() {
    return _instance;
  }
  
  // Private constructor
  AuthService._internal();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Create the user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create the user document in Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login timestamp
      if (userCredential.user != null) {
        await _firestoreService.updateUserProfile(
          userCredential.user!.uid, 
          {'lastLogin': FieldValue.serverTimestamp()}
        );
      }
      
      return userCredential;
    } catch (e) {
      print('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore first
        await _firestoreService.deleteUserDocument(user.uid);
        // Then delete the user account
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
