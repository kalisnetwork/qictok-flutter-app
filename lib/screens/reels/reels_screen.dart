import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reels_provider.dart';
import '../../widgets/reels/reel_tile.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReelsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            );
          }

          if (provider.posts.isEmpty) {
            return const Center(
              child: Text("No reels available.", style: TextStyle(color: Colors.white)),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: provider.posts.length,
            onPageChanged: (index) {
              if (index == provider.posts.length - 2) {
                provider.fetchPosts();
              }
            },
            itemBuilder: (context, index) {
              return ReelTile(
                post: provider.posts[index],
                isNext: index < provider.posts.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
