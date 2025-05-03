import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pakage/chat_page.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().logOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                }
              },
            ),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!mounted) return const SizedBox();

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users =
            snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where(
                  (user) =>
                      user['email'] != _auth.currentUser!.email &&
                      (user['name']?.toString().toLowerCase().contains(
                            _searchQuery,
                          ) ??
                          false),
                )
                .toList();

        if (users.isEmpty) {
          return Center(
            child: Text(
              _searchQuery.isEmpty
                  ? 'No contacts available'
                  : 'No matching contacts found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: users.length,
          separatorBuilder:
              (context, index) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserListItem(user, context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, BuildContext context) {
    final userName = user['name'] ?? user['email'].split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final status = user['status'] ?? 'Offline';
    final photoUrl = user['photoUrl'];

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blueAccent,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child:
            photoUrl == null
                ? Text(
                  userInitial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
                : null,
      ),
      title: Text(
        userName,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: status == 'Online' ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 6),
          ),
          Text(
            status,
            style: TextStyle(
              color: status == 'Online' ? Colors.green : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chat, color: Colors.blueAccent),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatPage(
                    receiveUserEmail: user['email'],
                    receiveUserID: user['uid'],
                    receiveUserName: userName,
                    receiveUserPhotoUrl: photoUrl,
                  ),
            ),
          );
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
