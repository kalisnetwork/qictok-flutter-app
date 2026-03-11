class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? 'user',
      fullName: json['fullname'],
      email: json['email'],
      avatarUrl: json['avatar_url'] ?? json['avatar'],
      bio: json['bio'],
      followersCount: json['stats']?['followers'] ?? 0,
      followingCount: json['stats']?['following'] ?? 0,
      postsCount: json['stats']?['posts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'fullname': fullName,
    'avatar_url': avatarUrl,
    'bio': bio,
  };
}
