class AppUser {
  final String id;
  final String email;
  final String name;
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiry;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  bool get isTokenExpired {
    if (tokenExpiry == null) return true;
    return DateTime.now().isAfter(tokenExpiry!.subtract(Duration(minutes: 5)));
  }

  String? getAccessToken() {
    return accessToken;
  }

  // convert app user to json
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }

  // convert json to app user
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'])
          : null,
    );
  }
}
