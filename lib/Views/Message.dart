import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gamershub/services/SessionManager.dart';
import '../Constant/constant.dart';
import 'package:http/http.dart' as http;
import '../models/Friend.dart';
import '_ChatPageState.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool _isLoading = true;
  List<Friend> _userFriends = [];
  Map<int, String> _lastMessages = {};

  Future<void> _fetchUserFriends() async {
    String? userId = await SessionManager.loadId();
    String? token = await SessionManager.loadToken();

    if (userId == null || token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('$FetchUserFriends$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _userFriends = List<Friend>.from(data.map((friend) => Friend.fromJson(friend)));

      // Fetch last messages
      await _fetchLastMessages(userId, token);
    } else {
      print('Failed to load user friends: ${response.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchLastMessages(String userId, String token) async {
    for (var friend in _userFriends) {
      final response = await http.get(
        Uri.parse('$addresse/api/messages/last/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final friendMessages = List<Map<String, dynamic>>.from(data);

        // Trouver le dernier message pour cet ami
        final lastMessage = friendMessages.firstWhere(
                (message) => message['friendId'] == friend.id);

        if (lastMessage != null) {
          setState(() {
            _lastMessages[friend.id] = lastMessage['lastMessage'] ?? 'No messages yet';
          });
        }
      } else {
        setState(() {
          _lastMessages[friend.id] = "No messages yet";
        });
      }
    }
  }


  Future<Uint8List?> _loadImageWithToken(String imageUrl) async {
    String? token = await SessionManager.loadToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(imageUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200 ? response.bodyBytes : null;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFriends();
  }

  void _navigateToChat(Friend friend) async {
    String? currentUserId = await SessionManager.loadId();
    if (currentUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            senderId: int.parse(currentUserId),
            receiverId: friend.id,
            receiverName: friend.firstName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recent Contacts",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _userFriends.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, i) {
                final friend = _userFriends[i];
                final imageUrl = friend.profilePicture != null
                    ? '$addresse${friend.profilePicture}'
                    : 'https://www.example.com/default-avatar.png';

                return InkWell(
                  onTap: () => _navigateToChat(friend),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: _loadImageWithToken(imageUrl),
                          builder: (context, snapshot) {
                            return Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: snapshot.hasData
                                    ? MemoryImage(snapshot.data!)
                                    : const NetworkImage('https://www.example.com/default-avatar.png') as ImageProvider,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 70,
                          child: Text(
                            friend.lastName,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "All Messages",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _userFriends.length,
              itemBuilder: (context, i) {
                final friend = _userFriends[i];
                final imageUrl = friend.profilePicture != null
                    ? '$addresse${friend.profilePicture}'
                    : 'https://www.example.com/default-avatar.png';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _navigateToChat(friend),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: _loadImageWithToken(imageUrl),
                            builder: (context, snapshot) {
                              return CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: snapshot.hasData
                                    ? MemoryImage(snapshot.data!)
                                    : const NetworkImage('https://www.example.com/default-avatar.png') as ImageProvider,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${friend.firstName} ${friend.lastName}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _lastMessages[friend.id] ?? 'No messages yet', // Last message
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
