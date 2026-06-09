import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_story.dart';

class StoriesList extends StatefulWidget {
  final Function(String)? onStoryTap;  // ← AJOUTER

  const StoriesList({
    super.key,
    this.onStoryTap,  // ← AJOUTER
  });

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  late NetworkService _networkService;
  List<NetworkStory> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _loading = true);
    try {
      final stories = await _networkService.getActiveStories();
      setState(() => _stories = stories);
    } catch (e) {
      debugPrint('Error loading stories: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_stories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stories professionnelles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              
              return GestureDetector(  // ← AJOUTER
                onTap: () => widget.onStoryTap?.call(story.id),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: story.isCurrentUser
                                  ? null
                                  : const LinearGradient(
                                      colors: [Color(0xFFD4AF37), Colors.orange],
                                    ),
                              border: story.isCurrentUser
                                  ? Border.all(color: Colors.grey.shade300, width: 2)
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: story.userAvatar != null
                                  ? NetworkImage(story.userAvatar!)
                                  : null,
                              child: story.userAvatar == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          if (story.isCurrentUser)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4AF37),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 16, color: Colors.white),
                              ),
                            ),
                          if (story.isViewed && !story.isCurrentUser)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.userName,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
