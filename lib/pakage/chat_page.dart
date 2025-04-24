import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/components/my_text_fild.dart';
import 'package:chat/service/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiveUserEmail;
  final String receiveUserID;

  const ChatPage({
    super.key,
    required this.receiveUserEmail,
    required this.receiveUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiveUserEmail)),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextFild(
              controlertext: _messageController,
              obscruteText: false,
              libertext: "Message...",
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 24),
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
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        // Scroll to bottom when messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 10),
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

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Text(
              data["senderEmail"],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  isCurrentUser
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
              bottomRight:
                  isCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
            ),
            color: isCurrentUser ? Colors.blue : Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                data["message"],
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
