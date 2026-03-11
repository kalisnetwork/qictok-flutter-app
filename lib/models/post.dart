class Post {
  final String id;
  final String? userId;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? description;
  final int likes;
  final int comments;
  final bool hasLiked;
  final User? user;

  Post({
    required this.id,
    this.userId,
    this.mediaUrl,
    this.thumbnailUrl,
    this.description,
    this.likes = 0,
    this.comments = 0,
    this.hasLiked = false,
    this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      hasLiked: json['hasLiked'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final String id;
  final String username;
  final String? avatar;

  User({required this.id, required this.username, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
    );
  }
}
