import 'package:gamershub/models/Person.dart';

class Post {
  final int id;
  final String description;
  final String urlMedia;
  final DateTime createdAt;
  final Person owner;
  int likeCount;
  int commentCount;
  List<String> likedBy;
  List<String> comments;

  Post({
    required this.id,
    required this.description,
    required this.urlMedia,
    required this.createdAt,
    required this.owner,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedBy = const [],
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic> likes = json['likes'] ?? [];
    List<dynamic> comments = json['comments'] ?? [];

    return Post(
      id: json['id'],
      description: json['description'],
      urlMedia: json['urlMedia'],
      createdAt: DateTime.parse(json['createdAt']),
      owner: Person.fromJson(json['userDTO']),
      likeCount: likes.length,
      commentCount: comments.length,
      likedBy: List<String>.from(likes),
      comments: List<String>.from(comments),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'urlMedia': urlMedia,
      'createdAt': createdAt.toIso8601String(),
      'userDTO': owner.toJson(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likes': likedBy,
      'comments': comments,
    };
  }

  void likePost(String userId) {
    if (!likedBy.contains(userId)) {
      likedBy.add(userId);
      likeCount++;
    }
  }

  void unlikePost(String userId) {
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      likeCount--;
    }
  }

  void addComment(String commentText) {
    comments.add(commentText);
    commentCount++;
  }

  void removeComment(String commentText) {
    comments.remove(commentText);
    commentCount--;
  }
}
