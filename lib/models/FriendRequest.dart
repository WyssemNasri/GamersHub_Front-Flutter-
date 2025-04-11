import 'Person.dart';

class FriendRequest {
  final int id;
  final Person sender;
  final Person receiver;
  final String status;

  FriendRequest({required this.id, required this.sender, required this.receiver, required this.status});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      sender: Person.fromJson(json['sender']),
      receiver: Person.fromJson(json['receiver']),
      status: json['status'],
    );
  }
}