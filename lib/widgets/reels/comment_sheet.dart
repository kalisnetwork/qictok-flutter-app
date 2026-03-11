import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/api_service.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CommentSheet extends StatefulWidget {
  final PostModel post;
  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _commentController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final resp = await _api.getComments(widget.post.id);
      if (resp.data['status'] == true) {
        setState(() {
          _comments = resp.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF1A1A1A).withOpacity(0.95), const Color(0xFF000000).withOpacity(0.95)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 15),
          const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const Divider(height: 30, color: Colors.white10),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
              : _comments.isEmpty 
                ? const Center(child: Text("No comments yet. Start the conversation!", style: TextStyle(color: Colors.grey, fontSize: 13)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return _buildCommentItem(c);
                    },
                  ),
          ),
          
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[900],
            backgroundImage: comment['user']?['avatar'] != null ? NetworkImage(comment['user']['avatar']) : null,
            child: comment['user']?['avatar'] == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${comment['user']?['username'] ?? 'user'}",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, 
        right: 10, 
        top: 10, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Add comment...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.redAccent),
            onPressed: () {
              // Handle submit
            },
          ),
        ],
      ),
    );
  }
}
