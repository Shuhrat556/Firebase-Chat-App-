import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String reciveID;
  final String message;
  final Timestamp timestame;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.reciveID,
    required this.message,
    required this.timestame,
  });

  Map<String, dynamic> toMap() {
    return {
     "senderID": senderID,       
    "senderEmail": senderEmail,  
    "erciveID": reciveID,        
    "message": message,          
    "timestame": timestame,  
    };
  }
}
