import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
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
  static const _appId = 'VOTRE_APP_ID_AGORA';
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isCameraOn = true;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _isJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: '',
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _toggleMute() async {
    await _engine.muteLocalAudioStream(!_isMuted);
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleCamera() async {
    await _engine.enableLocalVideo(!_isCameraOn);
    setState(() => _isCameraOn = !_isCameraOn);
  }

  Future<void> _endCall() async {
    await _engine.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vue principale (médecin)
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: const RtcConnection(channelId: ''),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Attente du médecin...',
                    style: TextStyle(color: Colors.white),
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
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
                    widget.doctorName,
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
                child: _TimerWidget(),
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
                    onPressed: () {},
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
