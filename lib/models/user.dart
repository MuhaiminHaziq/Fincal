class User {
  final String firstName;
  final String lastName;
  final String companyName;
  final String username;

  User({
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      companyName: json['companyName'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'username': username,
    };
  }

  String get fullName => '$firstName $lastName';
}

class UserWithPassword extends User {
  final String password;

  UserWithPassword({
    required super.firstName,
    required super.lastName,
    required super.companyName,
    required super.username,
    required this.password,
  });

  factory UserWithPassword.fromJson(Map<String, dynamic> json) {
    return UserWithPassword(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      companyName: json['companyName'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['password'] = password;
    return json;
  }
}
