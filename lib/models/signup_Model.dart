class SignupModel {
  String email;
  String password;
  String firstName;
  String lastName;
  String phoneNumber;
  DateTime dayOfBirth;
  SignupModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dayOfBirth,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dayOfBirth': dayOfBirth.toIso8601String(),

    };
  }
  factory SignupModel.fromMap(Map<String, dynamic> map) {
    return SignupModel(
      email: map['email'],
      password: map['password'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      dayOfBirth: DateTime.parse(map['dayOfBirth']),
    );
  }
  bool validate() {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        dayOfBirth.isBefore(DateTime.now());
  }
}
