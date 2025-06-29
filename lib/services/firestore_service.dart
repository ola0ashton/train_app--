// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  // Factory constructor to return the same instance each time
  factory FirestoreService() {
    return _instance;
  }

  // Private constructor
  FirestoreService._internal();

  // Create a new user document in Firestore
  Future<void> createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      });
      print('User document created successfully');
    } catch (e) {
      print('Error creating user document: $e');
      // Rethrow the error to be handled by the caller
      rethrow;
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Delete user document
  Future<void> deleteUserDocument(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('User document deleted successfully');
    } catch (e) {
      print('Error deleting user document: $e');
      rethrow;
    }
  }

  // Fetch FAQs grouped by category
  Future<Map<String, List<Map<String, dynamic>>>> fetchFaqsByCategory() async {
    final snapshot = await _firestore.collection('faqs').get();
    final faqs = snapshot.docs.map((doc) => doc.data()).toList();
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final faq in faqs) {
      final category = faq['category'] ?? 'General';
      if (!grouped.containsKey(category)) grouped[category] = [];
      grouped[category]!.add(faq);
    }
    return grouped;
  }
}
