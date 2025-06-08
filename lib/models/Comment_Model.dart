import 'package:gamershub/models/Person_Model.dart';

class CommentModel {
  final int id;
  final Person commentOwner;
  final String content;
  final String createdAt;


  CommentModel({
    required this.id,
    required this.commentOwner,
    required this.content,
    required this.createdAt,

  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      commentOwner: Person.fromJson(json['user']),
      createdAt: json['createdAt']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'userDTO': commentOwner.toJson(),
    };
  }
}
