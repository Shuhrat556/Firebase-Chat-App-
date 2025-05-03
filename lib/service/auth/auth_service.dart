import 'dart:io';

import 'package:chat/models/user_profile.dart';
import 'package:chat/service/auth/auth_gate.dart';
import 'package:chat/service/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _forebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<UserCredential> signinGmailandPassword(email, password) async {
    try {
      UserCredential userCredential = await _forebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _fireStore
          .collection('users')
          .doc(_forebaseAuth.currentUser!.uid)
          .get()
          .then(
            (value) => userCredential.user!.updateDisplayName(value['name']),
          );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithLoginPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // 1. Create user with email and password
      UserCredential userCredential = await _forebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

          final notificationService = NotificationService();
      await notificationService.initialize();

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();


      // 2. Update display name
      await userCredential.user!.updateDisplayName(name);

      // 3. Save user data to Firestore
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "status": "Offline", // Changed from "Unavalible" to "Offline"
        "uid": userCredential.user!.uid,
        "createdAt": token // Added timestamp
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future logOut(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut().then((value) {
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(builder: (_) => AuthGate()));
      });
    // ignore: empty_catches
    } catch (e) {
    }
  }

  //  Future<UserProfile> getProfile(String userId) async {
  //   DocumentSnapshot doc = await _fireStore.collection('users').doc(userId).get();
  //   return UserProfile.fromFirestore(doc);
  // }

  // Future<void> updateProfile(UserProfile profile) async {
  //   await _fireStore.collection('users').doc(profile.uid).update({
  //     'name': profile.name,
  //     'photoUrl': profile.photoUrl,
  //     'bio': profile.bio,
  //     'status': profile.status,
  //   });
    
  //   // Update auth display name if changed
  //   if (_forebaseAuth.currentUser?.displayName != profile.name) {
  //     await _forebaseAuth.currentUser?.updateDisplayName(profile.name);
  //   }
    
  //   notifyListeners();
  // }

  // Future<String?> uploadProfileImage(File imageFile) async {
  //   try {
  //     // String userId = _forebaseAuth.currentUser!.uid;
  //     // Reference storageRef = FirebaseStorage.instance
  //     //     .ref()
  //     //     .child('profile_images')
  //     //     .child('$userId.jpg');
      
  //     // UploadTask uploadTask = storageRef.putFile(imageFile);
  //     // TaskSnapshot snapshot = await uploadTask;
  //     // String downloadUrl = await snapshot.ref.getDownloadURL();
  //     // return downloadUrl;
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
