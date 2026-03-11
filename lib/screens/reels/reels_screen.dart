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
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (!provider.isLoading && provider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 60, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text("No reels available.", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: provider.refresh,
                    child: const Text("Retry", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
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
