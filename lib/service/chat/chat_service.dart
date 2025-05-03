import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:chat/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String reciveID, String message) async {
    final String curentUserID = _firebaseAuth.currentUser!.uid;
    final String curentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestame = Timestamp.now();

    final Message newMessage = Message(
      senderID: curentUserID,
      senderEmail: curentUserEmail,
      reciveID: reciveID,
      message: message,
      timestame: timestame,
    );
    List<String> isd = [curentUserID, reciveID];
    isd.sort();
    String chatRoomId = isd.join("-");

    await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(userId, otherUserId) {
    List<String> isd = [userId, otherUserId];
    isd.sort();
    String chatRoomsId = isd.join("-");

    return _fireStore
        .collection("chat_rooms")
        .doc(chatRoomsId)
        .collection("message")
        .orderBy("timestame", descending: false) 
        .snapshots();
  }
}
