import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gamershub/services/SessionManager.dart';
import '../Constant/constant.dart';
import 'package:http/http.dart' as http;
import '../models/Person_Model.dart';
import '../models/Message_Model.dart';
import '../services/MessageService.dart';
import '_ChatPageState.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final MessageService _messageService = MessageService();

  bool _isLoading = true;
  List<Person> _userFriends = [];
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
      _userFriends = List<Person>.from(data.map((friend) => Person.fromJson(friend)));

      // Fetch last messages
      await _fetchLastMessages(userId, token);
    } else {
      print('Failed to load user friends: ${response.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchLastMessages(String userId, String token) async {
    final futures = _userFriends.map((friend) async {
      try {
        final Message? lastMsg = await _messageService.fetchLastMessage(
          int.parse(userId),
          friend.id,
        );
        return MapEntry(friend.id, lastMsg?.content ?? "No messages yet");
      } catch (e) {
        return MapEntry(friend.id, "No messages yet");
      }
    });

    final results = await Future.wait(futures);
    setState(() {
      _lastMessages = Map.fromEntries(results);
    });
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

  void _navigateToChat(Person friend) async {
    String? currentUserId = await SessionManager.loadId();
    if (currentUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
              senderId: int.parse(currentUserId),
              receiverId: friend.id,
              receiverName: friend.firstName,
              friendUrlPic : friend.profilePicUrl
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _userFriends.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, i) {
                final friend = _userFriends[i];
                final imageUrl = friend.profilePicUrl != null
                    ? '$addresse${friend.profilePicUrl}'
                    : 'assets/images/default_profile_picture.png';

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
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: snapshot.hasData
                                    ? MemoryImage(snapshot.data!)
                                    : const AssetImage('assets/images/default_profile_picture.png') as ImageProvider,
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _userFriends.length,
              itemBuilder: (context, i) {
                final friend = _userFriends[i];
                final imageUrl = friend.profilePicUrl != null
                    ? '$addresse${friend.profilePicUrl}'
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
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
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
                                    : const AssetImage('assets/images/default_profile_picture.png') as ImageProvider,
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _lastMessages[friend.id] ?? 'No messages yet', // Last message
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
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
