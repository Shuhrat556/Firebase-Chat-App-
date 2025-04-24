import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _forebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<UserCredential> signinGmailandPassword(email, password) async {
    try {
      UserCredential userCredential = await _forebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
          _fireStore.collection("user").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
      },SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithLoginPassword(email, password) async {
    try {
      UserCredential userCredential = await _forebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _fireStore.collection("user").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
