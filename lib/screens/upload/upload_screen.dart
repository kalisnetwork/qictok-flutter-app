import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _api = ApiService();
  final _picker = ImagePicker();
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedFile = File(video.path);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a video first")),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      final tags = _tagsController.text.split(',').map((t) => t.trim()).toList();
      final resp = await _api.uploadPost(
        filePath: _selectedFile!.path,
        description: _descriptionController.text.trim(),
        tags: tags,
      );

      if (mounted) {
        if (resp.data['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post uploaded successfully!")),
          );
          _clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp.data['message'] ?? "Upload failed")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _clear() {
    _descriptionController.clear();
    _tagsController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _handleUpload,
            child: Text(
              _isUploading ? "..." : "Post",
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Select / Preview Placeholder
            AspectRatio(
              aspectRatio: 9 / 16,
              child: GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: _selectedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call, size: 50, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(height: 10),
                            Text(
                              "Tap to select video",
                              style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : const Center(
                          child: Icon(Icons.check_circle, size: 50, color: Colors.greenAccent),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Description
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tags
            const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add tags (e.g. funny, travel)...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Who can see this", style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text("Everyone", style: TextStyle(color: Colors.grey, fontSize: 13)),
                   Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
