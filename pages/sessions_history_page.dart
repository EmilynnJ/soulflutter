import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/reading_session.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';
import '../utils/soul_seer_colors.dart';

import 'dart:math' as math;

class SessionsHistoryPage extends StatefulWidget {
  const SessionsHistoryPage({super.key});

  @override
  State<SessionsHistoryPage> createState() => _SessionsHistoryPageState();
}

class _SessionsHistoryPageState extends State<SessionsHistoryPage>
    with TickerProviderStateMixin {
  UserModel? _currentUser;
  List<ReadingSession> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _starsController;
  late AnimationController _fadeController;
  late Animation<double> _starsAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadSessionHistory();
    _starsController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionHistory() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser == null) {
        setState(() {
          _errorMessage = 'Please log in to view your session history';
          _isLoading = false;
        });
        return;
      }

      // Load user\'s reading sessions
      final sessions = await EnhancedAuthService.getUserSessions(_currentUser!.id);
      
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load session history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Sessions',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: SoulSeerColors.mysticalPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: SoulSeerColors.mysticalPink,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A0033),
                Colors.black,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SoulSeerColors.mysticalPink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated stars background
            ...List.generate(60, (index) {
              return AnimatedBuilder(
                animation: _starsAnimation,
                builder: (context, child) {
                  final random = (index * 9999) % 1000 / 1000;
                  final x = (index * 37) % MediaQuery.of(context).size.width;
                  final y = (index * 73) % MediaQuery.of(context).size.height;
                  final opacity = (0.3 + 0.7 * ((index * 127) % 100) / 100) * 
                                 (0.5 + 0.5 * (1 + math.sin(_starsAnimation.value * 2 * math.pi + random * 2 * math.pi)) / 2);
                  
                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Main content
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: SoulSeerColors.mysticalPink,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              MysticalButton(
                text: 'Retry',
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadSessionHistory();
                },
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    final theme = Theme.of(context);
    
    if (_sessions.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SoulSeerColors.mysticalPink.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_fix_high,
                  size: 80,
                  color: SoulSeerColors.mysticalPink,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Sessions Yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your spiritual journey awaits! Book your first reading with our talented advisors.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                MysticalButton(
                  text: 'Find Readers',
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to explore page
                  },
                  icon: Icons.search,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderSection();
          }
          
          final session = _sessions[index - 1];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoulSeerColors.mysticalPink.withOpacity(0.1),
            SoulSeerColors.cosmicGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: SoulSeerColors.mysticalPink,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Session History',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your spiritual journey sessions with our gifted advisors',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SoulSeerColors.cosmicGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: SoulSeerColors.cosmicGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_sessions.length} Total Sessions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SoulSeerColors.cosmicGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ReadingSession session) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showSessionDetails(session),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: session.readerName != null
                          ? NetworkImage("https://pixabay.com/get/gddd6525ad78f1830e8c63e733c0a0c0e86fe97a253e7e18cdd27a51db954145f2cc7cfad0814b4eab4535e55ca1469868b8f53e42fec0ed5fdadcb8ee164e4ba_1280.jpg")
                          : null,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: session.readerName == null
                          ? Icon(
                              Icons.person,
                              color: theme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.readerName ?? 'Unknown Reader',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getReadingTypeDisplay(session.type),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(session.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusDisplay(session.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(session.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(session.startTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    if (session.endTime != null) ...[
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDurationText(session),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: SoulSeerColors.cosmicGold,
                    ),
                    Text(
                      '\$${session.totalCost?.toStringAsFixed(2) ?? '0.00'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: SoulSeerColors.cosmicGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (session.status == ReadingStatus.completed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: SoulSeerColors.cosmicGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.clientRating?.toString() ?? 'Rate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SoulSeerColors.cosmicGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getReadingTypeDisplay(ReadingType type) {
    switch (type) {
      case ReadingType.chat:
        return '💬 Chat Reading';
      case ReadingType.phone:
        return '📞 Phone Reading';
      case ReadingType.video:
        return '📹 Video Reading';
    }
  }

  String _getStatusDisplay(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.pending:
        return 'Pending';
      case ReadingStatus.active:
        return 'Active';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.pending:
        return Colors.orange;
      case ReadingStatus.active:
        return Colors.green;
      case ReadingStatus.completed:
        return SoulSeerColors.cosmicGold;
      case ReadingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getDurationText(ReadingSession session) {
    if (session.endTime == null) return '0 min';
    
    final duration = session.endTime!.difference(session.startTime);
    final minutes = duration.inMinutes;
    
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  void _showSessionDetails(ReadingSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSessionDetailsSheet(session),
    );
  }

  Widget _buildSessionDetailsSheet(ReadingSession session) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Details',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: SoulSeerColors.mysticalPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reader info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage("https://pixabay.com/get/g6314487e8f3a6a284632e5e658f8886c5559ec77faaacb6bf662d094159c63a71b056c52dc9be05906ef9921dfaea089a5463b4b5c0c98f8aad9767ed141d8ac_1280.jpg"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.readerName ?? 'Unknown Reader',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getReadingTypeDisplay(session.type),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Session info
                  _buildDetailRow('Date & Time', dateFormat.format(session.startTime)),
                  _buildDetailRow('Duration', _getDurationText(session)),
                  _buildDetailRow('Status', _getStatusDisplay(session.status)),
                  _buildDetailRow('Total Cost', '\$${session.totalCost?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildDetailRow('Per-minute Rate', '\$${session.perMinuteRate.toStringAsFixed(2)}'),
                  
                  if (session.clientRating != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Your Rating', '${session.clientRating} ⭐'),
                  ],
                  
                  if (session.clientReview != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Your Review',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        session.clientReview!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  if (session.status == ReadingStatus.completed && session.clientRating == null)
                    MysticalButton(
                      text: 'Rate & Review',
                      onPressed: () {
                        Navigator.pop(context);
                        _showRatingDialog(session);
                      },
                      icon: Icons.star,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(ReadingSession session) {
    // TODO: Implement rating dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }
}