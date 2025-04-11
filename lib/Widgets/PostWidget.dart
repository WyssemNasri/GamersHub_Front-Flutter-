import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/Post.dart';
import '../Constant/constant.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final String? token;

  const PostWidget({Key? key, required this.post, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the post
            Text(
              post.description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Time of the post
            Text(
              timeago.format(post.createdAt),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Media (image/video) if available
            if (post.urlMedia.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "$addresse${post.urlMedia}",
                  headers: {'Authorization': 'Bearer $token'},
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),

            // Like and Comment Count
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up, size: 22, color: Colors.blue),
                const SizedBox(width: 5),
                Text('${post.likeCount} Likes', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 20),
                Icon(Icons.comment, size: 22, color: Colors.grey),
                const SizedBox(width: 5),
                Text('${post.commentCount} Comments', style: TextStyle(fontSize: 14)),
              ],
            ),

            // Optional: Add a divider similar to Instagram's post layout
            const SizedBox(height: 10),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
