import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/post.dart';

class ReelTile extends StatefulWidget {
  final Post post;
  const ReelTile({super.key, required this.post});

  @override
  State<ReelTile> createState() => _ReelTileState();
}

class _ReelTileState extends State<ReelTile> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.post.mediaUrl == null) return;
    
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.post.mediaUrl!),
      formatHint: VideoFormat.hls,
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
      debugPrint("Video initialization error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(post: widget.post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6) {
          _controller.play();
        } else {
          _controller.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          // UI Overlays (Likes, Comments, Username)
          Positioned(
            left: 15,
            bottom: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.post.user?.username ?? 'user'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(widget.post.description ?? ''),
              ],
            ),
          ),
          
          Positioned(
            right: 15,
            bottom: 100,
            child: Column(
              children: [
                _buildAction(Icons.favorite, widget.post.likes.toString(), () {}),
                const SizedBox(height: 20),
                _buildAction(Icons.comment, widget.post.comments.toString(), _openComments),
                const SizedBox(height: 20),
                _buildAction(Icons.share, "Share", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 35, color: Colors.white),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
