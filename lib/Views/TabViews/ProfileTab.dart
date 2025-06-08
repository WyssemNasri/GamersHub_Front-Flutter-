import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gamershub/services/CommentService.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:http/http.dart' as http;
import '../../Constant/constant.dart';
import '../../Widgets/FriendsDialog.dart';
import '../../Widgets/PostWidget.dart';
import '../../models/Person_Model.dart';
import '../../models/Post_Model.dart';
import '../../services/SessionManager.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final LoadImageService loadImageService;
  late final CommentService commentService;

  String? _firstName, _lastName, _profilePic, _coverPic, _token;
  bool _isLoading = true;
  List<Post> _userPosts = [];
  List<Person> _userFriends = [];

  @override
  void initState() {
    super.initState();
    loadImageService = LoadImageService();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    _token = await SessionManager.loadToken();
    String? userId = await SessionManager.loadId();
    if (userId == null || _token == null) return;

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$FetchUserinformation$userId'),
            headers: {'Authorization': 'Bearer $_token'}),
        http.get(Uri.parse('$FetchUserPosts$userId'),
            headers: {'Authorization': 'Bearer $_token'}),
        http.get(Uri.parse('$FetchUserFriends$userId'),
            headers: {'Authorization': 'Bearer $_token'}),
      ]);

      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        _firstName = data['firstName'];
        _lastName = data['lastName'];
        _profilePic = data['profilePicture'];
        _coverPic = data['coverPicture'];
      }

      if (responses[1].statusCode == 200) {
        final posts = json.decode(responses[1].body);
        _userPosts = List<Post>.from(posts.map((post) => Post.fromJson(post)));
      }

      if (responses[2].statusCode == 200) {
        final friends = json.decode(responses[2].body);
        _userFriends =
        List<Person>.from(friends.map((f) => Person.fromJson(f)));
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    }

    setState(() => _isLoading = false);
  }

  Widget _buildNetworkImage(
      String? url, String fallback, double height, double width, BoxFit fit) {
    return FutureBuilder<ImageProvider>(
      future:
      loadImageService.fetchImage(url != null ? "$addresse$url" : fallback),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(
              height: height, width: width, color: Colors.grey[300]);
        if (snapshot.hasError)
          return Image.asset(fallback, height: height, width: width, fit: fit);
        return Image(
            image: snapshot.data!, height: height, width: width, fit: fit);
      },
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _coverPic != null
              ? loadImageService.showFullScreenImage(
              context, "$addresse$_coverPic")
              : null,
          child: _buildNetworkImage(_coverPic, 'assets/default_cover.jpg', 150,
              double.infinity, BoxFit.cover),
        ),
        Positioned(
          bottom: -40,
          child: GestureDetector(
            onTap: () => _profilePic != null
                ? loadImageService.showFullScreenImage(
                context, "$addresse$_profilePic")
                : null,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: _buildNetworkImage(
                    _profilePic,
                    'assets/images/default_profile_picture.png',
                    100,
                    100,
                    BoxFit.cover),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('${_userPosts.length} posts', Icons.post_add ),
          _buildStatColumn('${_userFriends.length} friends', Icons.group, _showFriendsDialog),
          _buildStatColumn('0 followers', Icons.people),  // Placeholder for followers
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, IconData icon, [VoidCallback? onTap]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showFriendsDialog() {
    showDialog(
      context: context,
      builder: (_) => FriendsDialog(
        userFriends: _userFriends, // The list of user friends
        addresse: addresse, // The address (URL base)
        loadImageService:
        loadImageService, // The loadImageService for image fetching
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              Text('$_firstName $_lastName',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildStats(),
            ],
          ),
        ),
        _userPosts.isNotEmpty
            ? SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, i) =>
                PostWidget(post: _userPosts[i], token: _token),
            childCount: _userPosts.length,
          ),
        )
            : const SliverToBoxAdapter(
            child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No posts available",
                      style: TextStyle(color: Colors.grey)),
                ))),
      ],
    );
  }
}
