// lib/presentation/admin/pages/create_news_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/news_provider.dart';
import '../../../models/news_article.dart';

class CreateNewsPage extends StatefulWidget {
  final NewsArticle? article;

  const CreateNewsPage({super.key, this.article});

  @override
  State<CreateNewsPage> createState() => _CreateNewsPageState();
}

class _CreateNewsPageState extends State<CreateNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedCategory = 'politique';
  bool _isFeatured = false;
  bool _isBreaking = false;
  DateTime _publishDate = DateTime.now();
  String? _imageUrl;
  String? _videoUrl;
  File? _imageFile;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'featured', 'label': 'À la une'},
    {'value': 'politique', 'label': 'Politique'},
    {'value': 'economie', 'label': 'Économie'},
    {'value': 'societe', 'label': 'Société'},
    {'value': 'tech', 'label': 'Tech'},
    {'value': 'sport', 'label': 'Sport'},
    {'value': 'culture', 'label': 'Culture'},
    {'value': 'international', 'label': 'International'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _summaryController.text = widget.article!.summary ?? '';
      _contentController.text = widget.article!.content;
      _selectedCategory = widget.article!.category;
      _isFeatured = widget.article!.isFeatured;
      _isBreaking = widget.article!.isBreaking;
      _publishDate = widget.article!.publishedAt;
      _imageUrl = widget.article!.imageUrl;
      _videoUrl = widget.article!.videoUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() => _imageFile = File(result.files.first.path!));
      }
    } catch (e) {
      _showError('Erreur lors de la sélection de l\'image');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return null;
    
    final provider = context.read<NewsProvider>();
    final url = await provider.uploadImage(_imageFile!.path);
    return url;
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      String? uploadedImageUrl = _imageUrl;
      if (_imageFile != null) {
        uploadedImageUrl = await _uploadImage();
      }
      
      final provider = context.read<NewsProvider>();
      
      if (widget.article != null) {
        // Mise à jour
        await provider.updateArticle(widget.article!.id, {
          'title': _titleController.text.trim(),
          'summary': _summaryController.text.trim(),
          'content': _contentController.text.trim(),
          'category': _selectedCategory,
          'image_url': uploadedImageUrl,
          'video_url': _videoUrl,
          'is_featured': _isFeatured,
          'is_breaking': _isBreaking,
          'published_at': _publishDate.toIso8601String(),
        });
        _showSuccess('Article modifié avec succès');
      } else {
        // Création
        await provider.createArticle(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrl: uploadedImageUrl,
          videoUrl: _videoUrl,
          isFeatured: _isFeatured,
          isBreaking: _isBreaking,
        );
        _showSuccess('Article créé avec succès');
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectPublishDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publishDate),
      );
      if (time != null) {
        setState(() {
          _publishDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1B3D),
        elevation: 0,
        title: Text(
          widget.article != null ? 'Modifier l\'article' : 'Nouvel article',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveArticle,
            child: Text(
              widget.article != null ? 'MODIFIER' : 'PUBLIER',
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    
                    // Titre
                    TextFormField(
                      controller: _titleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Titre de l\'article',
                        hintText: 'Titre accrocheur...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Résumé
                    TextFormField(
                      controller: _summaryController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Résumé (optionnel)',
                        hintText: 'Court résumé de l\'article...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Contenu
                    TextFormField(
                      controller: _contentController,
                      maxLines: 15,
                      decoration: const InputDecoration(
                        labelText: 'Contenu',
                        hintText: 'Contenu complet de l\'article...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Contenu requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat['value'],
                          child: Text(cat['label']!, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    
                    // Options
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            value: _isFeatured,
                            onChanged: (v) => setState(() => _isFeatured = v),
                            title: const Text('À la une', style: TextStyle(fontSize: 13)),
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFFD4AF37),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            value: _isBreaking,
                            onChanged: (v) => setState(() => _isBreaking = v),
                            title: const Text('Breaking', style: TextStyle(fontSize: 13)),
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Date de publication
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date de publication', style: TextStyle(fontSize: 13)),
                      subtitle: Text(
                        '${_publishDate.day}/${_publishDate.month}/${_publishDate.year} ${_publishDate.hour}:${_publishDate.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: _selectPublishDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // URL Vidéo (optionnel)
                    TextFormField(
                      controller: TextEditingController(text: _videoUrl),
                      onChanged: (v) => _videoUrl = v,
                      decoration: const InputDecoration(
                        labelText: 'URL Vidéo (optionnel)',
                        hintText: 'https://youtube.com/...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
              )
            : _imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_imageUrl!, fit: BoxFit.cover, width: double.infinity),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Ajouter une image', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
      ),
    );
  }
}
