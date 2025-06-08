import 'package:gamershub/models/Person_Model.dart';

class Post {
  final int id;
  final String? description;
  final String? urlMedia;
  final DateTime createdAt;
  final Person owner;
  final int likeCount;
  final int commentCount;


  Post({
    required this.id,
    required this.description,
    required this.urlMedia,
    required this.createdAt,
    required this.owner,
    required this.likeCount,
    required this.commentCount
  });

  factory Post.fromJson(Map<String, dynamic> json) {

    return Post(
      id: json['id'],
      description: json['description'],
      urlMedia: json['urlMedia'],
      createdAt: DateTime.parse(json['createdAt']),
      owner: Person.fromJson(json['userDTO']),
      likeCount: json["likeCount"] ,
      commentCount : json["commentCount"]

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
    };
  }


}
