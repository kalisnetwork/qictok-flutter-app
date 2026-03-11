import 'user_model.dart';

enum PostType { video, image }

class PostModel {
  final String id;
  final String? userId;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? description;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool hasLiked;
  final UserModel? user;
  final PostType type;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    this.userId,
    this.mediaUrl,
    this.thumbnailUrl,
    this.description,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.hasLiked = false,
    this.user,
    this.type = PostType.video,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final mediaId = json['media_id'];
    String? mediaUrl = json['media_url'];
    String? thumbnailUrl = json['thumbnail_url'];

    // If the backend sends an absolute URL, use it. 
    // If it's relative or missing, and we have a mediaId, construct the CDN link.
    if (mediaId != null && (mediaUrl == null || !mediaUrl.startsWith('http'))) {
      mediaUrl = 'https://cdn.digitalleadpro.com/v1/m/$mediaId/index.m3u8';
      thumbnailUrl = 'https://cdn.digitalleadpro.com/v1/m/$mediaId/index.webp';
    }

    return PostModel(
      id: json['id'] ?? '',
      userId: json['user_id']?.toString(),
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      likesCount: json['likes'] ?? 0,
      commentsCount: json['comments'] ?? 0,
      viewsCount: json['views'] ?? 0,
      hasLiked: json['hasLiked'] ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      type: (json['type'] == 'image') ? PostType.image : PostType.video,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
