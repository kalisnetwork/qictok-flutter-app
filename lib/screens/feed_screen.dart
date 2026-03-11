import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/reel_tile.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ApiService _api = ApiService();
  final List<Post> _posts = [];
  bool _isLoading = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await _api.getPosts(page: _page);
      if (response.data['status'] == true) {
        final List newPostsJson = response.data['data'];
        setState(() {
          _posts.addAll(newPostsJson.map((p) => Post.fromJson(p)).toList());
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        onPageChanged: (index) {
          if (index == _posts.length - 2) {
            _page++;
            _fetchPosts();
          }
        },
        itemBuilder: (context, index) {
          return ReelTile(post: _posts[index]);
        },
      ),
    );
  }
}
