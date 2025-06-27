import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/reading_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/mystical_button.dart';

class ReadingSessionPage extends StatefulWidget {
  final UserModel reader;
  final ReadingType readingType;

  const ReadingSessionPage({
    super.key,
    required this.reader,
    required this.readingType,
  });

  @override
  State<ReadingSessionPage> createState() => _ReadingSessionPageState();
}

class _ReadingSessionPageState extends State<ReadingSessionPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _starsController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _timerPulse;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  ReadingStatus _sessionStatus = ReadingStatus.pending;
  
  int _sessionDuration = 0;
  double _sessionCost = 0.0;
  bool _isConnected = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _startSession();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _timerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_starsController);

    _timerPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _timerController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _startSession() {
    setState(() {
      _sessionStatus = ReadingStatus.active;
      _isConnected = true;
    });
    
    // Start timer for session duration
    _startSessionTimer();
    
    // Add welcome message from reader
    _addSystemMessage('${widget.reader.fullName} has joined the session. Welcome! ✨');
  }

  void _startSessionTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted && _sessionStatus == ReadingStatus.active) {
        setState(() {
          _sessionDuration++;
          _sessionCost = _sessionDuration * _getPerMinuteRate();
        });
        _startSessionTimer();
      }
    });
  }

  double _getPerMinuteRate() {
    final profile = widget.reader.readerProfile;
    if (profile == null) return 0.0;
    
    switch (widget.readingType) {
      case ReadingType.chat:
        return profile.chatRate;
      case ReadingType.phone:
        return profile.phoneRate;
      case ReadingType.video:
        return profile.videoRate;
    }
  }

  void _addSystemMessage(String message) {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: 'current_session',
      senderId: 'system',
      message: message,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.insert(0, systemMessage);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: 'current_session',
      senderId: _currentUser!.id,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.insert(0, message);
    });
    
    _messageController.clear();
    
    // Simulate reader response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _simulateReaderResponse();
    });
  }

  void _simulateReaderResponse() {
    final responses = [
      'I\'m sensing strong energy around you. Let me pull some cards... 🔮',
      'The universe is speaking to me about your situation. I see clarity coming your way.',
      'Your chakras are telling me an interesting story. There\'s transformation ahead.',
      'The spirits are guiding me to tell you that new opportunities are approaching.',
      'I\'m getting visions of positive changes in your love life. Trust the process.',
      'Your guardian angels want you to know that you\'re on the right path.',
      'The tarot cards are showing me that abundance is coming into your life.',
      'I sense someone from your past will reconnect with you soon.',
    ];
    
    final randomResponse = responses[math.Random().nextInt(responses.length)];
    
    final readerMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: 'current_session',
      senderId: widget.reader.id,
      message: randomResponse,
      timestamp: DateTime.now(),
    );
    
    if (mounted) {
      setState(() {
        _messages.insert(0, readerMessage);
      });
    }
  }

  void _endSession() {
    setState(() {
      _sessionStatus = ReadingStatus.completed;
      _isConnected = false;
    });
    
    _showSessionSummary();
  }

  void _showSessionSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSessionSummary(),
    );
  }

  Widget _buildSessionSummary() {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: SoulSeerColors.mysticalGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Session Complete',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Duration', '${_sessionDuration} minutes'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Rate', '\$${_getPerMinuteRate().toStringAsFixed(2)}/min'),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Cost', '\$${_sessionCost.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Rate Your Experience',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    color: SoulSeerColors.cosmicGold,
                    size: 32,
                  ),
                );
              }),
            ),
            const Spacer(),
            
            Row(
              children: [
                Expanded(
                  child: MysticalButton(
                    text: 'Book Again',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    isSecondary: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MysticalButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF1A0033),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated stars background
            AnimatedBuilder(
              animation: _starsAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarfieldPainter(_starsAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(theme),
                      _buildSessionInfo(theme),
                      Expanded(child: _buildChatArea(theme)),
                      if (_sessionStatus == ReadingStatus.active) _buildMessageInput(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          MysticalIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          
          CircleAvatar(
            radius: 24,
            backgroundColor: SoulSeerColors.mysticalPink,
            child: Text(
              widget.reader.fullName.isNotEmpty ? widget.reader.fullName[0].toUpperCase() : 'R',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reader.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isConnected ? 'Connected' : 'Connecting...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_sessionStatus == ReadingStatus.active)
            MysticalIconButton(
              icon: Icons.call_end,
              onPressed: _endSession,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _timerPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _timerPulse.value,
                child: Icon(
                  Icons.schedule,
                  color: SoulSeerColors.cosmicGold,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            '${_sessionDuration}:00',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '\$${_sessionCost.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: SoulSeerColors.cosmicGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: _messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your reading session has started',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation with your reader',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isFromCurrentUser = _currentUser != null && message.senderId == _currentUser!.id;
                final isSystemMessage = message.senderId == 'system';
                
                return _buildMessageBubble(message, isFromCurrentUser, isSystemMessage, theme);
              },
            ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isFromCurrentUser, bool isSystemMessage, ThemeData theme) {
    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: SoulSeerColors.cosmicGold.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: SoulSeerColors.cosmicGold,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: SoulSeerColors.mysticalPink,
              child: Text(
                widget.reader.fullName.isNotEmpty ? widget.reader.fullName[0].toUpperCase() : 'R',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isFromCurrentUser 
                    ? SoulSeerColors.mysticalGradient
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: !isFromCurrentUser ? Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ) : null,
              ),
              child: Text(
                message.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: SoulSeerColors.deepPurple,
              child: Text(
                _currentUser?.fullName.isNotEmpty == true ? _currentUser!.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: SoulSeerColors.mysticalPink.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            MysticalIconButton(
              icon: Icons.send,
              onPressed: _sendMessage,
              color: SoulSeerColors.mysticalPink,
            ),
          ],
        ),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double animationValue;
  
  StarfieldPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    
    for (int i = 0; i < 100; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 89 + animationValue * 50) % size.height;
      final opacity = (0.1 + (i % 5) * 0.2);
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}