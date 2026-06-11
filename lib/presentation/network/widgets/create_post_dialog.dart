// lib/presentation/network/widgets/create_post_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/network_service.dart';
import '../../../providers/feed_provider.dart';

class CreatePostDialog extends StatefulWidget {
  final String? communityId;
  final VoidCallback? onPostCreated;
  
  const CreatePostDialog({super.key, this.communityId, this.onPostCreated});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final List<String> _uploadingFiles = [];
  bool _isUploading = false;
  String? _errorMessage;
  int _selectedPostType = 0;
  
  List<Map<String, dynamic>> _mentionSuggestions = [];
  bool _showMentions = false;
  String _currentMentionQuery = '';

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final text = _contentController.text;
    final lastAtIndex = text.lastIndexOf('@');
    
    if (lastAtIndex != -1 && lastAtIndex == text.length - 1) {
      setState(() {
        _showMentions = true;
        _currentMentionQuery = '';
      });
    } else if (lastAtIndex != -1 && text.length > lastAtIndex + 1) {
      final query = text.substring(lastAtIndex + 1);
      if (query.contains(' ') || query.contains('\n')) {
        setState(() => _showMentions = false);
      } else {
        setState(() {
          _showMentions = true;
          _currentMentionQuery = query;
        });
        _searchUsers(query);
      }
    } else {
      setState(() => _showMentions = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    try {
      final networkService = Provider.of<NetworkService>(context, listen: false);
      final users = await networkService.searchUsers(query);
      if (mounted) {
        setState(() => _mentionSuggestions = users);
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
    }
  }

  void _insertMention(Map<String, dynamic> user) {
    final text = _contentController.text;
    final lastAtIndex = text.lastIndexOf('@');
    final beforeMention = text.substring(0, lastAtIndex);
    final newText = '$beforeMention@${user['display_name']} ';
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() => _showMentions = false);
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() {
          for (final file in result.files) {
            if (file.path != null) {
              _selectedImages.add(File(file.path!));
            }
          }
          _selectedPostType = _selectedImages.isNotEmpty ? 1 : 0;
        });
      }
    } catch (e) {
      _showError('Impossible de charger les images');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty && result.files.first.path != null && mounted) {
        setState(() {
          _selectedVideos.add(File(result.files.first.path!));
          _selectedPostType = 2;
        });
      }
    } catch (e) {
      _showError('Impossible de charger la vidéo');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty && _selectedVideos.isEmpty) {
        _selectedPostType = 0;
      }
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideos.clear();
      _selectedPostType = 0;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && 
        _selectedImages.isEmpty && 
        _selectedVideos.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez écrire quelque chose ou ajouter du contenu';
      });
      return;
    }
    
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    
    try {
      final networkService = Provider.of<NetworkService>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      
      List<String> mediaUrls = [];
      
      // Upload des images
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        if (mounted) {
          setState(() => _uploadingFiles.add('Image ${i + 1}'));
        }
        
        final url = await networkService.uploadImage(image.path);
        if (url != null) mediaUrls.add(url);
        
        if (mounted) {
          setState(() => _uploadingFiles.remove('Image ${i + 1}'));
        }
      }
      
      // Upload des vidéos
      for (int i = 0; i < _selectedVideos.length; i++) {
        final video = _selectedVideos[i];
        if (mounted) {
          setState(() => _uploadingFiles.add('Vidéo ${i + 1}'));
        }
        
        final url = await networkService.uploadImage(video.path);
        if (url != null) mediaUrls.add(url);
        
        if (mounted) {
          setState(() => _uploadingFiles.remove('Vidéo ${i + 1}'));
        }
      }
      
      bool success = false;
      
      if (widget.communityId != null) {
        final postId = await networkService.createCommunityPost(
          communityId: widget.communityId!,
          content: _contentController.text.trim(),
          images: mediaUrls,
        );
        success = postId.isNotEmpty;
        if (success) {
          await feedProvider.loadFeed();
        }
      } else {
        success = await feedProvider.createPost(
          _contentController.text.trim(),
          mediaUrls,
        );
      }
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication créée avec succès'), backgroundColor: Colors.green),
        );
        widget.onPostCreated?.call();
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Échec de la création');
      }
      
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width > 600 ? 550 : double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Nouvelle publication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildTypeButton(Icons.text_fields, 'Texte', 0),
                  const SizedBox(width: 8),
                  _buildTypeButton(Icons.image, 'Image', 1),
                  const SizedBox(width: 8),
                  _buildTypeButton(Icons.videocam, 'Vidéo', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Écrivez votre publication... Utilisez #hashtag ou @mention',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            if (_uploadingFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: _uploadingFiles.map((text) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Text(text),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            if (_selectedImages.isNotEmpty)
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) => Stack(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.green),
                  onPressed: _isUploading ? null : _pickImages,
                  tooltip: 'Ajouter des images',
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.orange),
                  onPressed: _isUploading ? null : _pickVideo,
                  tooltip: 'Ajouter une vidéo',
                ),
                const Spacer(),
                TextButton(onPressed: _isUploading ? null : () => Navigator.pop(context), child: const Text('Annuler')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B1B3D),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('PUBLIER'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Utilisez #hashtag pour les tendances | @mention pour taguer',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(IconData icon, String label, int type) {
    final isSelected = _selectedPostType == type;
    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPostType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
