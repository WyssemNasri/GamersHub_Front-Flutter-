import 'package:flutter/material.dart';
import 'package:gamershub/Widgets/CommentBottomShit.dart';
import 'package:gamershub/Widgets/customShowBottomSheet.dart';
import 'package:gamershub/models/Comment_Model.dart';
import 'package:gamershub/models/Like.dart';
import 'package:gamershub/services/CommentService.dart';
import 'package:gamershub/services/LikeService.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../../models/Post_Model.dart';
import '../Constant/constant.dart';
import '../Providers/ThemeNotifier.dart';
import '../Providers/FontNotifier.dart';
import '../services/SessionManager.dart';
class PostWidget extends StatefulWidget {
  final Post post;
  final String? token;

  const PostWidget({Key? key, required this.post, required this.token})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final CommentService commentService = CommentService();
  final LikeService likeService = LikeService();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  Future<void> checkIfLiked() async {
    final token = widget.token;
    if (token == null) return;

    final likes = await likeService.getAllLikesInPost(widget.post.id);
    final userId = await SessionManager.loadId();

    if (!mounted) return;
    setState(() {
      isLiked = likes.any((person) => person.id == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;
    final loadImageService = LoadImageService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and user info
          FutureBuilder<ImageProvider>(
            future: loadImageService.fetchImage('$addresse${widget.post.owner.profilePicUrl}'),
            builder: (context, snapshot) {
              Widget avatar = const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                avatar = CircleAvatar(
                  radius: 22,
                  backgroundImage: snapshot.data,
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                avatar = const CircleAvatar(
                  radius: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                  backgroundColor: Colors.grey,
                );
              }

              return Row(
                children: [
                  avatar,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.post.owner.firstName} ${widget.post.owner.lastName}',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          timeago.format(widget.post.createdAt),
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.grey.shade600),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Post Description
          if (widget.post.description != null && widget.post.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                widget.post.description!,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Media (Image or Video)
          if (widget.post.urlMedia != null && widget.post.urlMedia!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "$addresse${widget.post.urlMedia}",
                headers: {'Authorization': 'Bearer ${widget.token}'},
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),

          // Action Buttons (Like, Comment, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Like Button
              InkWell(
                onTap: () async {
                  await likeService.likePost(widget.post.id);
                  if (!mounted) return;
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                  color: isLiked ? Colors.red : Colors.grey.shade700,
                ),
              ),

              // Like Count (adjusted to reduce space)
              GestureDetector(
                onTap: () async {
                  List<Like_Model> likes = await likeService.getAllLikesInPost(widget.post.id);
                  customShowBottomSheet(context, likes);
                },
                child: Text(
                  '${widget.post.likeCount}',
                  style: TextStyle(fontFamily: fontFamily),
                ),
              ),

              // Comments Button
              GestureDetector(
                child: Row(
                  children: [
                    Icon(Icons.mode_comment_outlined, size: 22, color: Colors.grey.shade700),
                    const SizedBox(width: 4), // Reduced space between icon and count
                    Text('${widget.post.commentCount}', style: TextStyle(fontFamily: fontFamily)),
                  ],
                ),
                onTap: () async {
                  List<CommentModel> CommentsOnpost = await commentService.fetchCommentByPost(widget.post.id);
                  customShowCommentBottomSheet(context, CommentsOnpost, widget.post.id);
                },
              ),

              // Share Button
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 22, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text('Partager', style: TextStyle(fontFamily: fontFamily)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
