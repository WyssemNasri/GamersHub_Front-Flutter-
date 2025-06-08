import 'Person_Model.dart';

class FriendRequest {
  final int id;
  final Person sender;
  final String status;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['requestId'] ?? 0,
      sender: Person.fromJson(json['user'] ?? {}),
      status: json['status'] ?? '',
    );
  }
}
