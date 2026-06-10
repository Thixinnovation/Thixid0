import 'package:flutter/material.dart';
import 'dart:async';

class TeleconsultationPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String channelName;

  const TeleconsultationPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.channelName,
  });

  @override
  State<TeleconsultationPage> createState() => _TeleconsultationPageState();
}

class _TeleconsultationPageState extends State<TeleconsultationPage> {
  bool _isMuted = false;
  bool _isCameraOn = true;

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOn = !_isCameraOn);
  }

  Future<void> _endCall() async {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vue principale (médecin) - Simulée
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade800,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Dr. ${widget.doctorName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'En consultation...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Vue locale (patient)
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Icon(
                    _isCameraOn ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Dr. ${widget.doctorName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Timer
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const _TimerWidget(),
              ),
            ),
          ),

          // Contrôles
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: _toggleMute,
                  color: _isMuted ? Colors.red : Colors.white,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: _endCall,
                  color: Colors.red,
                  isEnd: true,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onPressed: _toggleCamera,
                  color: _isCameraOn ? Colors.white : Colors.red,
                ),
              ],
            ),
          ),

          // Chat button
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => _showChatSheet(),
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.chat, color: Color(0xFF0B1B3D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isEnd = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEnd ? Colors.red : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isEnd ? Colors.white : color),
      ),
    );
  }

  void _showChatSheet() {
    final messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              const Text(
                'Chat avec le médecin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 0,
                  itemBuilder: (context, index) => Container(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Votre message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat bientôt disponible')),
                      );
                    },
                    icon: const Icon(Icons.send),
                    color: const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  Duration _duration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _duration += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: const TextStyle(color: Colors.white),
    );
  }
}
