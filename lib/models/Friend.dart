

class Friend {
  final int id;
  final String firstName;
  final String lastName;
  final String profilePicture;

  Friend({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? 0,  // Default value for id if null
      firstName: json['firstName'] ?? 'Unknown',  // Default value for firstName if null
      lastName: json['lastName'] ?? 'Unknown',    // Default value for lastName if null
      profilePicture: json['profilePicture'] ?? 'assets/images/default_profile_picture.png',  // Default value for profilePicture if null
    );
  }
}
