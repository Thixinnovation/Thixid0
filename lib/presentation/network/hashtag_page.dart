// lib/presentation/network/hashtag_page.dart
import 'package:flutter/material.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/services/network_service.dart';

class HashtagPage extends StatefulWidget {
  final String tag;
  const HashtagPage({super.key, required this.tag});

  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  late NetworkService _networkService;
  List<NetworkPost> _posts = [];
  Hashtag? _hashtagInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final hashtagInfo = await _networkService.getHashtagInfo(widget.tag);
      final posts = await _networkService.getPostsByHashtag(widget.tag);
      setState(() {
        _hashtagInfo = hashtagInfo;
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.tag}'),
        actions: [
          if (_hashtagInfo != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${_hashtagInfo!.postsCount} posts'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) => _buildPostItem(_posts[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tag, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('#${widget.tag}', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          const Text('Aucun post pour ce hashtag'),
        ],
      ),
    );
  }

  Widget _buildPostItem(NetworkPost post) {
    return GestureDetector(
      onTap: () => context.push('/network/post/${post.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (post.mediaUrl != null)
            Image.network(post.mediaUrl!, fit: BoxFit.cover)
          else
            Container(color: Colors.grey[200], child: const Icon(Icons.text_fields)),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('${post.likesCount}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
