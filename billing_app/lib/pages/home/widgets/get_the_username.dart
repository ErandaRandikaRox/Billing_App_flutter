
import 'package:billing_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<String> fetchUsername(AuthService authService) async {
  try {
    User? currentUser = authService.getCurrentUser();
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('username') ?? 'User';
      } else {
        return 'User';
      }
    } else {
      return 'User';
    }
  } catch (e) {
    debugPrint("Error fetching username: $e");
    return 'User';
  }
}
