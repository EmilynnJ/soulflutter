import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../theme.dart';
import '../models/reading_session.dart';
import '../models/user_model.dart';
import '../services/webrtc_service.dart' as webrtc;
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';

class EnhancedReadingSessionPage extends StatefulWidget {
  final UserModel reader;
  final ReadingType readingType;

  const EnhancedReadingSessionPage({
    super.key,
    required this.reader,
    required this.readingType,
  });

  @override
  State<EnhancedReadingSessionPage> createState() => _EnhancedReadingSessionPageState();
}

class _EnhancedReadingSessionPageState extends State<EnhancedReadingSessionPage> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _timerPulse;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final webrtc.WebRTCService _webrtcService = webrtc.WebRTCService.instance;
  
  ReadingSession? _currentSession;
  UserModel? _currentUser;
  int _sessionDuration = 0;
  double _sessionCost = 0.0;
  bool _isConnected = false;
  bool _isCameraEnabled = true;
  bool _isMicrophoneEnabled = true;
  String? _connectionError;

  // Agora rendering
  int? _localUid;
  int? _remoteUid;
  bool _isAgoraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSession();
    _setupWebRTCListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _starsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_starsController);
    
    _timerPulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _starsController.repeat();
    _timerController.repeat(reverse: true);
  }

  Future<void> _initializeSession() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser == null) {
        _showError('Please log in to start a reading session');
        return;
      }

      // Initialize WebRTC service
      await _webrtcService.initialize();

      // Create reading session
      _currentSession = ReadingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: _currentUser!.id,
        readerId: widget.reader.id,
        type: widget.readingType,
        status: ReadingStatus.pending,
        perMinuteRate: _getPerMinuteRate(),
        startTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Start WebRTC session
      await _webrtcService.startReadingSession(
        session: _currentSession!,
        currentUser: _currentUser!,
        remoteUser: widget.reader,
        type: widget.readingType,
      );

    } catch (e) {
      _showError('Failed to initialize session: $e');
    }
  }

  void _setupWebRTCListeners() {
    // Connection state changes
    _webrtcService.connectionStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isConnected = state == webrtc.ConnectionState.connected;
        });
      }
    });

    // Call state changes
    _webrtcService.callStateStream.listen((state) {
      if (state == webrtc.CallState.ended) {
        _showSessionSummary();
      }
    });

    // Local user joined
    _webrtcService.localUserJoinedStream.listen((uid) {
      if (mounted) {
        setState(() {
          _localUid = uid;
        });
      }
    });

    // Remote user joined
    _webrtcService.remoteUserJoinedStream.listen((uid) {
      if (mounted) {
        setState(() {
          _remoteUid = uid;
        });
      }
    });

    // Remote user left
    _webrtcService.remoteUserLeftStream.listen((uid) {
      if (mounted) {
        setState(() {
          if (_remoteUid == uid) {
            _remoteUid = null;
          }
        });
      }
    });

    // Messages and updates
    _webrtcService.messageStream.listen((message) {
      if (!mounted) return;
      
      switch (message['type']) {
        case 'session_update':
          setState(() {
            _sessionDuration = message['duration'];
            _sessionCost = message['cost'];
          });
          break;
        case 'session_ended':
          _showSessionSummary();
          break;
        case 'camera_toggled':
          setState(() {
            _isCameraEnabled = message['enabled'];
          });
          break;
        case 'microphone_toggled':
          setState(() {
            _isMicrophoneEnabled = message['enabled'];
          });
          break;
      }
    });

    // Errors
    _webrtcService.errorStream.listen((error) {
      _showError(error);
    });
  }

  double _getPerMinuteRate() {
    switch (widget.readingType) {
      case ReadingType.chat:
        return widget.reader.readerProfile?.chatRate ?? 2.99;
      case ReadingType.phone:
        return widget.reader.readerProfile?.phoneRate ?? 4.99;
      case ReadingType.video:
        return widget.reader.readerProfile?.videoRate ?? 6.99;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    setState(() {
      _connectionError = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSessionSummary() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(_sessionDuration)}'),
            Text('Cost: \$${_sessionCost.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Thank you for your session!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Animated starfield background
          AnimatedBuilder(
            animation: _starsAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: StarfieldPainter(_starsAnimation.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Video area
                Expanded(
                  child: _buildVideoArea(),
                ),
                
                // Chat area
                if (widget.readingType == ReadingType.chat)
                  _buildChatArea(),
                
                // Controls
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Reader info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reader.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.readingType.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Session info
          AnimatedBuilder(
            animation: _timerPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _timerPulse.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatDuration(_sessionDuration),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_sessionCost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (widget.readingType == ReadingType.chat) {
      return _buildChatInterface();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Remote video (main view)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black87,
              child: _remoteUid != null && webrtc.WebRTCService.instance.agoraEngine != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: webrtc.WebRTCService.instance.agoraEngine!,
                        canvas: VideoCanvas(uid: _remoteUid),
                        connection: const RtcConnection(channelId: 'test'),
                      ),
                    )
                  : _buildPlaceholderVideo(isRemote: true),
            ),
            
            // Local video (picture-in-picture)
            if (widget.readingType == ReadingType.video)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _localUid != null && webrtc.WebRTCService.instance.agoraEngine != null
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: webrtc.WebRTCService.instance.agoraEngine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : _buildPlaceholderVideo(isRemote: false),
                  ),
                ),
              ),
            
            // Connection status
            if (!_isConnected)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Connecting...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderVideo({required bool isRemote}) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: isRemote ? 64 : 32,
              color: Colors.white54,
            ),
            const SizedBox(height: 8),
            Text(
              isRemote ? 'Waiting for ${widget.reader.displayName}' : 'Camera Off',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
                fontSize: isRemote ? 16 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _currentUser?.id;
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isMe 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Message input
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: _buildChatInterface(),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          MysticalButton(
            text: _isMicrophoneEnabled ? 'Mute' : 'Unmute',
            onPressed: () => _webrtcService.toggleMicrophone(),
            icon: _isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
            color: _isMicrophoneEnabled 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          
          // Camera toggle (only for video calls)
          if (widget.readingType == ReadingType.video)
            MysticalButton(
              text: _isCameraEnabled ? 'Camera Off' : 'Camera On',
              onPressed: () => _webrtcService.toggleCamera(),
              icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              color: _isCameraEnabled 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          
          // End call
          MysticalButton(
            text: 'End Call',
            onPressed: () => _webrtcService.endCall(),
            icon: Icons.call_end,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSession?.id ?? '',
      senderId: _currentUser?.id ?? '',
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(message);
    });
    
    _messageController.clear();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _timerController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class StarfieldPainter extends CustomPainter {
  final double animationValue;
  
  StarfieldPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(opacity * 0.3);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  
  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}