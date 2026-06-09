import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/services/upload_service.dart';

class CreateStoryDialog extends StatefulWidget {
  const CreateStoryDialog({super.key});

  @override
  State<CreateStoryDialog> createState() => _CreateStoryDialogState();
}

class _CreateStoryDialogState extends State<CreateStoryDialog> {
  File? _selectedImage;
  bool _isUploading = false;
  late NetworkService _networkService;
  late UploadService _uploadService;
  int _duration = 24; // heures

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _uploadService = UploadService();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = File(result.files.first.path!);
      });
    }
  }

  Future<void> _createStory() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadService.uploadStoryImage(_selectedImage!);
      await _networkService.createStory(imageUrl, duration: _duration);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story publiée !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ajouter une story',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tapez pour sélectionner'),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Durée: '),
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 6,
                    max: 48,
                    divisions: 42,
                    label: '$_duration heures',
                    onChanged: (value) {
                      setState(() => _duration = value.toInt());
                    },
                  ),
                ),
                Text('$_duration h'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _createStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('PUBLIER LA STORY'),
            ),
          ],
        ),
      ),
    );
  }
}
