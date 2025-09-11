class AppUser {
  final String id;
  final String email;
  final String name;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
  });

  // convert app user to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  // convert json to app user
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}