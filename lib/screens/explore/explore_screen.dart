import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reels_provider.dart';
import '../../models/post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  List<PostModel> _searchResults = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await context.read<ReelsProvider>().searchPosts(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearch,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search QicTok...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: SpinKitPulse(color: Colors.red, size: 50))
          : _searchResults.isNotEmpty
              ? _buildGrid(_searchResults)
              : Consumer<ReelsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.posts.isEmpty) {
                      return const Center(child: SpinKitPulse(color: Colors.red, size: 50));
                    }
                    return _buildGrid(provider.posts);
                  },
                ),
    );
  }

  Widget _buildGrid(List<PostModel> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Text("No results found", style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildGridItem(context, post);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () {
        // Full screen view implementation
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post.thumbnailUrl ?? 'https://via.placeholder.com/300x450/000000/FFFFFF?text=Post',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[900]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          if (post.type == PostType.video)
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.white, size: 12),
                const SizedBox(width: 3),
                Text(
                  post.likesCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
