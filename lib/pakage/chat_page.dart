import 'package:chat/models/user_profile.dart';
import 'package:chat/pakage/profile_screen.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/components/my_text_fild.dart';
import 'package:chat/service/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiveUserName;
  final String receiveUserEmail;
  final String receiveUserID;
  final String receiveUserPhotoUrl;

  const ChatPage({
    super.key,
    required this.receiveUserName,
    required this.receiveUserEmail,
    required this.receiveUserID,
    required this.receiveUserPhotoUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FocusNode _messageFocusNode = FocusNode();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        widget.receiveUserID,
        _messageController.text.trim(),
        
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: // In your ChatPage's AppBar
          AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProfileScreen(
                      userId: widget.receiveUserID,
                      isCurrentUser: false,
                    ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.receiveUserPhotoUrl),
                child:
                    // ignore: unnecessary_null_comparison
                    widget.receiveUserPhotoUrl == null
                        ? Text(widget.receiveUserName[0])
                        : null,
              ),
              const SizedBox(width: 12),
              Text(widget.receiveUserName),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
      // drawer: // In your HomePage or main navigation
      //     Drawer(
      //   child: FutureBuilder<UserProfile>(
      //     future: _authService.getProfile(_auth.currentUser!.uid),
      //     builder: (context, snapshot) {
      //       if (!snapshot.hasData) {
      //         return const DrawerHeader(child: CircularProgressIndicator());
      //       }

      //       final profile = snapshot.data!;

      //       return ListView(
      //         children: [
      //           UserAccountsDrawerHeader(
      //             accountName: Text(profile.name),
      //             accountEmail: Text(profile.email),
      //             currentAccountPicture: CircleAvatar(
      //               backgroundImage:
      //                   profile.photoUrl != null
      //                       ? NetworkImage(profile.photoUrl!)
      //                       : null,
      //               child:
      //                   profile.photoUrl == null ? Text(profile.name[0]) : null,
      //             ),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.person),
      //             title: const Text('My Profile'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder:
      //                       (_) => ProfileScreen(
      //                         userId: _auth.currentUser!.uid,
      //                         isCurrentUser: true,
      //                       ),
      //                 ),
      //               );
      //             },
      //           ),
      //           // ... other menu items
      //         ],
      //       );
      //     },
      //   ),
      // ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: MyTextFild(
              controlertext: _messageController,
              obscruteText: false,
              libertext: "Type a message...",
              // focusNode: _messageFocusNode,
              // onSubmitted: (value) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserId = _firebaseAuth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessage(widget.receiveUserID, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading messages",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final currentUserId = _firebaseAuth.currentUser?.uid ?? '';
    final isCurrentUser = data["senderID"] == currentUserId;
    final timestamp = data["timestamp"] as Timestamp?;
    final time =
        timestamp != null
            ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
            : '';
    final isRead = data["isRead"] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                widget.receiveUserName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment:
                  isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blueAccent : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft:
                          isCurrentUser
                              ? const Radius.circular(12)
                              : const Radius.circular(4),
                      bottomRight:
                          isCurrentUser
                              ? const Radius.circular(4)
                              : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    data["message"],
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: isRead ? Colors.blue : Colors.grey.shade600,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required bool isCurrentUser, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("data"),),
    );
  }
}