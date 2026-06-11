// lib/presentation/network/widgets/create_post_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
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
  final List<String> _uploadingImages = [];
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // Utiliser uniquement FilePicker (pas besoin d'image_picker)
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
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      _showError('Impossible de charger les images');
    }
  }

  // Pas de caméra sans image_picker, on utilise file_picker aussi
  // ou on désactive cette option
  Future<void> _pickCamera() async {
    _showError('Fonctionnalité caméra à venir. Utilisez "Ajouter des images" pour l\'instant');
  }

  Future<void> _pickFile() async {
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
        });
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      _showError('Impossible de charger les fichiers');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez écrire quelque chose ou ajouter une image';
      });
      return;
    }
    
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    
    try {
      final networkService = Provider.of<NetworkService>(context, listen: false);
      
      // Upload des images vers Supabase Storage
      List<String> imageUrls = [];
      
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        setState(() {
          _uploadingImages.add('Image ${i + 1}');
        });
        
        final url = await networkService.uploadImage(image.path);
        if (url != null) {
          imageUrls.add(url);
        } else {
          _showError('Erreur lors de l\'upload de l\'image ${i + 1}');
        }
        
        setState(() {
          _uploadingImages.remove('Image ${i + 1}');
        });
      }
      
      // Créer le post même si certaines images ont échoué
      if (imageUrls.isNotEmpty || _contentController.text.trim().isNotEmpty) {
        if (widget.communityId != null) {
          await networkService.createCommunityPost(
            communityId: widget.communityId!,
            content: _contentController.text.trim(),
            images: imageUrls,
          );
        } else {
          await networkService.createPost(
            _contentController.text.trim(),
            imageUrls,
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication créée avec succès'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Aucune image téléchargée avec succès');
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
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
                  tooltip: 'Fermer',
                ),
              ],
            ),
            
            const Divider(),
            
            // Champ de texte
            const Text(
              'Que voulez-vous partager ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Écrivez votre publication...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Indicateur de upload
            if (_uploadingImages.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (var text in _uploadingImages)
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
            
            // Aperçu des images sélectionnées
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
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            // Message d'erreur
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
            
            // Boutons d'ajout
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.green),
                  onPressed: _isUploading ? null : _pickImages,
                  tooltip: 'Ajouter des images',
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.orange),
                  onPressed: _isUploading ? null : _pickCamera,
                  tooltip: 'Prendre une photo (bientôt disponible)',
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.blue),
                  onPressed: _isUploading ? null : _pickFile,
                  tooltip: 'Ajouter des fichiers',
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
                'Les images sont stockées de façon sécurisée',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
