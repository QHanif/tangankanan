class User {
  final String userId;
  final String username;
  final String email;
  final DateTime birthdate;
  final String phoneNumber;
  final DateTime registerDate;
  final String role;
  final List<String> createdProjects;
  final List<String> backedProjects;
  final String profilePictureUrl;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.birthdate,
    required this.phoneNumber,
    required this.registerDate,
    required this.role,
    required this.createdProjects,
    required this.backedProjects,
    required this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      birthdate: DateTime.parse(json['birthdate']),
      phoneNumber: json['phoneNumber'],
      registerDate: DateTime.parse(json['registerDate']),
      role: json['role'],
      createdProjects: List<String>.from(json['createdProjects']),
      backedProjects: List<String>.from(json['backedProjects']),
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  User copyWith({
    String? userId,
    String? username,
    String? email,
    DateTime? birthdate,
    String? phoneNumber,
    DateTime? registerDate,
    String? role,
    List<String>? createdProjects,
    List<String>? backedProjects,
    String? profilePictureUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registerDate: registerDate ?? this.registerDate,
      role: role ?? this.role,
      createdProjects: createdProjects ?? this.createdProjects,
      backedProjects: backedProjects ?? this.backedProjects,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'birthdate': birthdate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'registerDate': registerDate.toIso8601String(),
      'role': role,
      'createdProjects': createdProjects,
      'backedProjects': backedProjects,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
