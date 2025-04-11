import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gamershub/Constant/constant.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:provider/provider.dart';
import '../Providers/MessageProvider.dart';
import '../models/message.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<Image> _loadImageWithAuth(String profilePicUrl) async {
    String? token = await SessionManager.loadToken();
    if (token == null) {
      return Image.asset('assets/default_profile_pic.png'); // Default image if no token
    }

    final response = await http.get(
      Uri.parse(profilePicUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // If image is fetched successfully
      return Image.memory(response.bodyBytes);
    } else {
      // In case of failure, return default image
      return Image.asset('assets/default_profile_pic.png');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Connect to the message provider to listen for messages
    Provider.of<MessageProvider>(context, listen: false)
        .connect(widget.senderId, widget.receiverId);
  }

  @override
  void dispose() {
    // Disconnect from message provider and dispose controllers
    Provider.of<MessageProvider>(context, listen: false).disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);

    // Scroll to the bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder<Image>(
              future: _loadImageWithAuth("https://$addresse/profile_pic.jpg"), // Change to your actual image URL
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(radius: 20, child: CircularProgressIndicator());
                }
                return CircleAvatar(radius: 20, backgroundImage: snapshot.data?.image);
              },
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Navigate to profile page or settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: ValueKey(messageProvider.messages.length),
              controller: _scrollController,
              itemCount: messageProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = messageProvider.messages[index];
                final isMe = msg.senderId == widget.senderId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey.shade400,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.content,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    // Open emoji picker
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      final message = Message(
                        senderId: widget.senderId,
                        receiverId: widget.receiverId,
                        content: _controller.text.trim(),
                        createdAt: DateTime.now().toString(),
                      );
                      messageProvider.sendMessage(message);
                      _controller.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
