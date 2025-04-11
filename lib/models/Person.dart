class Person {
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePicUrl;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicUrl,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicUrl: json['profilePicUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicUrl': profilePicUrl, // Handle optional profilePicUrl
    };
  }

}
