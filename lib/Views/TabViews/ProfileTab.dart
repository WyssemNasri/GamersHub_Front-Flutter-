import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Constant/constant.dart';
import '../../Widgets/PostWidget.dart';
import '../../models/Friend.dart';
import '../../models/Post.dart';
import '../../services/SessionManager.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _firstName;
  String? _lastName;
  String? _profilePic;
  String? _coverPic;
  String? _token;
  bool _isLoading = true;
  List<Post> _userPosts = [];
  List<Friend> _userFriends = [];
  int _friendCount = 0;

  // Fetch user friends from API
  Future<void> _fetchUserFriends() async {
    String? userId = await SessionManager.loadId();
    String? token = await SessionManager.loadToken();

    if (userId == null || token == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$FetchUserFriends$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _userFriends = List<Friend>.from(
          data.map((friend) => Friend.fromJson(friend)),
        );
        _friendCount = _userFriends.length;
      });
    } else {
      print('Failed to load user friends. Status code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  // Fetch user posts from API
  Future<void> _fetchUserPosts() async {
    String? userId = await SessionManager.loadId();
    String? token = await SessionManager.loadToken();

    if (userId == null || token == null) {
      print('User ID or token is missing');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$FetchUserPosts$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _userPosts = List<Post>.from(data.map((post) => Post.fromJson(post)));
      });
    } else {
      print('Failed to load user posts. Status code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  // Fetch user data from API
  Future<void> _fetchUserData() async {
    String? userId = await SessionManager.loadId();
    _token = await SessionManager.loadToken();

    if (userId == null || _token == null) {
      print('User ID or token is missing');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$FetchUserinformation$userId'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _firstName = data['firstName'];
        _lastName = data['lastName'];
        _profilePic = data['profilePicture'];
        _coverPic = data['coverPicture'];
        _isLoading = false;
      });
    } else {
      print('Failed to load user data. Status code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserPosts();
    _fetchUserFriends();
  }

  // Fetch image from URL with token in header
  Future<ImageProvider> _fetchImage(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return MemoryImage(response.bodyBytes);
    } else {
      return const AssetImage('assets/images/default_profile_picture.png');
    }
  }

  // Show full-screen image in a dialog
  Future<void> _showFullScreenImage(BuildContext context, String imageUrl) async {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 3.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<ImageProvider>(
                  future: _fetchImage(imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Image.asset('assets/images/default_profile_picture.png', fit: BoxFit.cover);
                    }
                    return Hero(
                      tag: imageUrl,
                      child: Image(
                        image: snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  if (_coverPic != null) {
                    _showFullScreenImage(context, "$addresse$_coverPic");
                  }
                },
                child: FutureBuilder<ImageProvider>(
                  future: _fetchImage(
                    _coverPic != null ? "$addresse$_coverPic" : 'assets/default_cover.jpg',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                      );
                    }
                    if (snapshot.hasError) {
                      return Image.asset(
                        'assets/default_cover.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }
                    return Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -40,
                child: GestureDetector(
                  onTap: () {
                    if (_profilePic != null) {
                      _showFullScreenImage(context, "$addresse$_profilePic");
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: FutureBuilder<ImageProvider>(
                        future: _fetchImage(
                          _profilePic != null ? "$addresse$_profilePic" : 'assets/images/default_profile_picture.png',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Image.asset('assets/images/default_profile_picture.png', fit: BoxFit.cover);
                          }
                          return Image(image: snapshot.data!, fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          !_isLoading && _firstName != null && _lastName != null
              ? Text(
            '$_firstName $_lastName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20),
          // Display friends count with tap to show in alert dialog
          !_isLoading
              ? GestureDetector(
            onTap: () {
              // Show friends in an AlertDialog when tapped
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Friends'),
                    content: SizedBox(
                      height: 300,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: _userFriends.length,
                        itemBuilder: (context, index) {
                          final friend = _userFriends[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('$addresse${friend.profilePicture}'),
                            ),
                            title: Text('${friend.firstName} ${friend.lastName}'),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              '$_friendCount friends',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20),
          // Display posts
          !_isLoading && _userPosts.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                return PostWidget(post: _userPosts[index], token: _token);
              },
            ),
          )
              : const CircularProgressIndicator(),
        ],
      ),
    );
  }
}