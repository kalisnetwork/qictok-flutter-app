import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class ReelsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final List<PostModel> _posts = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  ReelsProvider() {
    refresh();
  }

  void reset() {
    _posts.clear();
    _page = 1;
    _hasMore = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 1;
    _posts.clear();
    _hasMore = true;
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await _api.getPosts(page: _page, limit: 10);
      if (resp.data['status'] == true) {
        final List data = resp.data['data'];
        final List<PostModel> newPosts = data.map((p) => PostModel.fromJson(p)).toList();
        
        // Deduplicate
        for (var newPost in newPosts) {
          if (!_posts.any((p) => p.id == newPost.id)) {
            _posts.add(newPost);
          }
        }
        
        _hasMore = newPosts.length >= 10;
        _page++;
      }
    } catch (e) {
      debugPrint("Fetch posts error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final resp = await _api.searchPosts(query);
      if (resp.data['status'] == true) {
        final List data = resp.data['data'];
        return data.map((p) => PostModel.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
    return [];
  }

  Future<List<PostModel>> fetchUserPosts(String userId) async {
    try {
      final resp = await _api.getUserPosts(userId);
      if (resp.data['status'] == true) {
        final List data = resp.data['data'];
        return data.map((p) => PostModel.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint("Fetch user posts error: $e");
    }
    return [];
  }

  Future<void> likePost(String postId) async {
    try {
      final resp = await _api.likePost(postId);
      if (resp.data['status'] == true) {
        // Update local state for immediate feedback
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          final hasLiked = resp.data['data']['hasLiked'] ?? !post.hasLiked;
          final likes = resp.data['data']['likes'] ?? (hasLiked ? post.likesCount + 1 : post.likesCount - 1);
          
          _posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            mediaUrl: post.mediaUrl,
            thumbnailUrl: post.thumbnailUrl,
            description: post.description,
            tags: post.tags,
            likesCount: likes,
            commentsCount: post.commentsCount,
            hasLiked: hasLiked,
            user: post.user,
            type: post.type,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Like post error: $e");
    }
  }
}
