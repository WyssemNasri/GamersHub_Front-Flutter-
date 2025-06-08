import 'Person_Model.dart';

class Like_Model {
  final int id;
  final Person user;
  final bool liked;

  Like_Model({
    required this.id,
    required this.user,
    required this.liked,
  });

  factory Like_Model.fromJson(Map<String, dynamic> json) {
    return Like_Model(
      id: json['id'],
      user: Person.fromJson(json['user']),
      liked: json['liked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'liked': liked,
    };
  }
}
