import 'package:flutter/material.dart';
import 'package:gamershub/services/post_service.dart';
import 'package:gamershub/services/ImageService.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../Widgets/StatusInputWidget.dart';
import 'package:gamershub/models/Post.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PostService postService = PostService();
  Set<int> likedPosts = Set<int>(); // To keep track of liked posts

  void _handlePostedStatus(String status) {
    setState(() {}); // Refresh the UI after posting a status
  }

  void _toggleLike(Post post, String userId) {
    setState(() {
      if (post.likedBy.contains(userId)) {
        post.unlikePost(userId); // Unlike the post
      } else {
        post.likePost(userId); // Like the post
      }
    });
  }

  void _addComment(Post post, String comment) {
    setState(() {
      post.addComment(comment); // Add comment to the post
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusInputWidget(onStatusPosted: _handlePostedStatus),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: postService.fetchUserPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts available.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data![index];
                    String formattedDate = timeago.format(post.createdAt, locale: 'fr');

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FutureBuilder<ImageProvider>(
                                  future: ImageService.fetchImage(post.owner.profilePicUrl),
                                  builder: (context, snapshot) {
                                    return CircleAvatar(
                                      radius: 25,
                                      backgroundImage: snapshot.hasData
                                          ? snapshot.data!
                                          : const AssetImage('assets/images/default_profile_picture.png'),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${post.owner.firstName} ${post.owner.lastName}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(post.description, style: const TextStyle(fontSize: 14)),
                            if (post.urlMedia.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: FutureBuilder<ImageProvider>(
                                  future: ImageService.fetchImage(post.urlMedia),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return snapshot.hasData
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image(image: snapshot.data!, fit: BoxFit.cover),
                                    )
                                        : const Center(child: Text('Image load error'));
                                  },
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    post.likedBy.contains('userId') ? Icons.favorite : Icons.favorite_border,
                                    color: post.likedBy.contains('userId') ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => _toggleLike(post, 'userId'), // Replace with actual user ID
                                ),
                                Text('${post.likeCount} Likes'),
                                const SizedBox(width: 10),
                                Text('${post.commentCount} Comments'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Add a comment',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (comment) => _addComment(post, comment),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
