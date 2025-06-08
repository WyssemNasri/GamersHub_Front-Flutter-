import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamershub/Widgets/PostWidget.dart';
import 'package:gamershub/services/post_service.dart';
import '../../Widgets/StatusInputWidget.dart';
import 'package:gamershub/models/Post_Model.dart';
import 'package:gamershub/services/SessionManager.dart';
import '../../services/WinkDetector.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PostService postService = PostService();
  final ScrollController _scrollController = ScrollController();
  final WinkDetector winkDetector = WinkDetector();

  Future<List<Post>>? _futurePosts;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeWinkDetection();
  }

  void _loadData() async {
    final fetchedToken = await SessionManager.loadToken();
    setState(() {
      token = fetchedToken;
      _futurePosts = postService.fetchFriendsPosts();
    });
  }

  void _handlePostedStatus(String status) {
    _loadData();
  }

  void _initializeWinkDetection() async {
    await winkDetector.initialize();

    Timer.periodic(const Duration(seconds:1 ), (_) async {
      final wink = await winkDetector.startWinkDetection();
      if (wink == 'left') {
        _scrollDown();
      } else if (wink == 'right') {
        _scrollUp();
      }
    });
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.offset + 600.0;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
    );
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.offset - 600.0;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    winkDetector.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        StatusInputWidget(onStatusPosted: _handlePostedStatus),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: _futurePosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              final posts = snapshot.data ?? [];
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PostWidget(post: post, token: token),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
