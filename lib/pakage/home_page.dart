import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pakage/chat_page.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthService>().signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("user").snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Text("Error!!");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loadding...");
        }
        return ListView(
          children:
              snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItem(doc, context))
                  .toList(),
        );
      },
    );
  }

  _buildUserListItem(DocumentSnapshot doc, context) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data["email"]) {
      return ListTile(
        title: Text(data["email"]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatPage(
                    receiveUserEmail: data["email"],
                    receiveUserID: data["uid"],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
