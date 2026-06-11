// lib/presentation/network/widgets/create_post_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../services/network_service.dart';

class CreatePostDialog extends StatefulWidget {
  final String? communityId;
  
  const CreatePostDialog({super.key, this.communityId});

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
  int _selectedPostType = 0; // 0: Texte, 1: Image, 2: Vidéo, 3: Sondage
  
  // Pour les sondages
  bool _isPoll = false;
  String _pollQuestion = '';
  final List<TextEditingController> _pollOptions = [];
  int _pollDuration = 24; // heures
  DateTime? _pollEndDate;
  
  // Pour les suggestions de mentions
  List<Map<String, dynamic>> _mentionSuggestions = [];
  bool _showMentions = false;
  String _currentMentionQuery = '';

  @override
  void initState() {
    super.initState();
    _pollOptions.addAll([TextEditingController(), TextEditingController()]);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pollOptions.forEach((c) => c.dispose());
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
    final networkService = Provider.of<NetworkService>(context, listen: false);
    final users = await networkService.searchUsers(query);
    setState(() => _mentionSuggestions = users);
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
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final file in result.files) {
            if (file.path != null) {
              _selectedImages.add(File(file.path!));
            }
          }
          _selectedPostType = 1;
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
      
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        setState(() {
          _selectedVideos.add(File(result.files.first.path!));
          _selectedPostType = 2;
        });
      }
    } catch (e) {
      _showError('Impossible de charger la vidéo');
    }
  }

  void _addPollOption() {
    setState(() {
      _pollOptions.add(TextEditingController());
    });
  }

  void _removePollOption(int index) {
    if (_pollOptions.length > 2) {
      setState(() {
        _pollOptions[index].dispose();
        _pollOptions.removeAt(index);
      });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && 
        _selectedImages.isEmpty && 
        _selectedVideos.isEmpty &&
        !_isPoll) {
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
      
      List<String> mediaUrls = [];
      
      // Upload des images
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        setState(() {
          _uploadingFiles.add('Image ${i + 1}');
        });
        
        final url = await networkService.uploadImage(image.path);
        if (url != null) {
          mediaUrls.add(url);
        }
        
        setState(() {
          _uploadingFiles.remove('Image ${i + 1}');
        });
      }
      
      // Upload des vidéos
      for (int i = 0; i < _selectedVideos.length; i++) {
        final video = _selectedVideos[i];
        setState(() {
          _uploadingFiles.add('Vidéo ${i + 1}');
        });
        
        final url = await networkService.uploadVideo(video.path);
        if (url != null) {
          mediaUrls.add(url);
        }
        
        setState(() {
          _uploadingFiles.remove('Vidéo ${i + 1}');
        });
      }
      
      // Création du post
      if (_isPoll && _pollQuestion.isNotEmpty) {
        // Créer un sondage
        final options = _pollOptions.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        await networkService.createPollPost(
          content: _contentController.text.trim(),
          question: _pollQuestion,
          options: options,
          duration: _pollDuration,
        );
      } else if (_selectedPostType == 2 && mediaUrls.isNotEmpty) {
        // Créer une vidéo courte (Reel)
        await networkService.createReel(
          videoUrl: mediaUrls.first,
          caption: _contentController.text.trim(),
        );
      } else {
        // Post normal
        if (widget.communityId != null) {
          await networkService.createCommunityPost(
            communityId: widget.communityId!,
            content: _contentController.text.trim(),
            images: mediaUrls,
          );
        } else {
          await networkService.createPost(
            _contentController.text.trim(),
            mediaUrls,
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication créée avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isUploading = false;
      });
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
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nouvelle publication',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const Divider(),
            
            // Types de post
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildTypeButton(Icons.text_fields, 'Texte', 0),
                  const SizedBox(width: 8),
                  _buildTypeButton(Icons.image, 'Image', 1),
                  const SizedBox(width: 8),
                  _buildTypeButton(Icons.videocam, 'Vidéo', 2),
                  const SizedBox(width: 8),
                  _buildTypeButton(Icons.poll, 'Sondage', 3),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Zone de texte avec suggestions de mentions
            Stack(
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: _isPoll ? 'Ajoutez une description (optionnel)...' : 'Écrivez votre publication... Utilisez #hashtag ou @mention',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                if (_showMentions && _mentionSuggestions.isNotEmpty)
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Column(
                        children: _mentionSuggestions.map((user) => ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: user['photo_url'] != null 
                                ? NetworkImage(user['photo_url']) 
                                : null,
                            child: user['photo_url'] == null ? const Icon(Icons.person, size: 16) : null,
                          ),
                          title: Text(user['display_name']),
                          subtitle: Text('@${user['display_name']}'),
                          onTap: () => _insertMention(user),
                        )).toList(),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Section Sondage
            if (_isPoll) ...[
              const Divider(),
              TextField(
                onChanged: (value) => _pollQuestion = value,
                decoration: const InputDecoration(
                  labelText: 'Question du sondage',
                  hintText: 'Que voulez-vous demander ?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ..._pollOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_pollOptions.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removePollOption(index),
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addPollOption,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une option'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Durée: '),
                  DropdownButton<int>(
                    value: _pollDuration,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 heure')),
                      DropdownMenuItem(value: 6, child: Text('6 heures')),
                      DropdownMenuItem(value: 12, child: Text('12 heures')),
                      DropdownMenuItem(value: 24, child: Text('24 heures')),
                      DropdownMenuItem(value: 72, child: Text('3 jours')),
                      DropdownMenuItem(value: 168, child: Text('7 jours')),
                    ],
                    onChanged: (value) => setState(() => _pollDuration = value!),
                  ),
                ],
              ),
              const Divider(),
            ],
            
            // Upload progress
            if (_uploadingFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (var text in _uploadingFiles)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(text),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            
            // Images preview
            if (_selectedImages.isNotEmpty)
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            // Video preview
            if (_selectedVideos.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam, size: 48, color: Colors.white54),
                          const SizedBox(height: 8),
                          Text(
                            'Vidéo prête à être publiée',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeVideo,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Actions
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
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B1B3D),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('PUBLIER'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Info
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
    final isSelected = _selectedPostType == type && !_isPoll;
    return Flexible(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPostType = type;
            _isPoll = type == 3;
            if (type != 3) {
              _pollQuestion = '';
              _pollOptions.forEach((c) => c.clear());
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
