import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/post_model.dart';
import '../../providers/reels_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'comment_sheet.dart';

class ReelTile extends StatefulWidget {
  final PostModel post;
  final bool isNext;
  const ReelTile({super.key, required this.post, this.isNext = false});

  @override
  State<ReelTile> createState() => _ReelTileState();
}

class _ReelTileState extends State<ReelTile> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late AnimationController _likeAnimController;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final url = widget.post.mediaUrl;
    if (url == null) return;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await _controller.initialize();
      _controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Video error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLike() {
    context.read<ReelsProvider>().likePost(widget.post.id);
    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6) {
          if (_isInitialized) _controller.play();
        } else {
          if (_isInitialized) _controller.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background/Video
          _isInitialized
              ? GestureDetector(
                  onTap: () {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : _buildShimmer(),

          // Bottom Gradient/Overlay
          _buildInfoOverlay(),

          // Side Actions (Likes/Comments/Share/Avatar)
          _buildSideActions(),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(color: Colors.black),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@${widget.post.user?.username ?? 'user'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (widget.post.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.post.tags.map((t) => '#$t').join(' '),
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSideActions() {
    return Positioned(
      right: 15,
      bottom: 100,
      child: Column(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(height: 25),

          // Like
          _buildAction(
            icon: widget.post.hasLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            color: widget.post.hasLiked ? Colors.red : Colors.white,
            label: widget.post.likesCount.toString(),
            onTap: _handleLike,
          ),
          const SizedBox(height: 20),

          // Comment
          _buildAction(
            icon: FontAwesomeIcons.commentDots,
            label: widget.post.commentsCount.toString(),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CommentSheet(post: widget.post),
              );
            },
          ),
          const SizedBox(height: 20),

          // Share
          _buildAction(
            icon: FontAwesomeIcons.share,
            label: 'Share',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            image: DecorationImage(
              image: NetworkImage(widget.post.user?.avatarUrl ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=user'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAction({required IconData icon, Color color = Colors.white, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
