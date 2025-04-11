class LastMessageFriend {
  final int friendId;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String lastMessage;
  final String timestamp;

  LastMessageFriend({
    required this.friendId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.lastMessage,
    required this.timestamp,
  });

  factory LastMessageFriend.fromJson(Map<String, dynamic> json) {
    return LastMessageFriend(
      friendId: json['friendId'],
      firstName: json['friendFirstName'],
      lastName: json['friendLastName'],
      profilePicture: json['profilePicture'],
      lastMessage: json['lastMessage'],
      timestamp: json['timestamp'],
    );
  }
}
