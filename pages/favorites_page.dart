import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';
import '../utils/soul_seer_colors.dart';

import 'reader_detail_page.dart';
import 'dart:math' as math;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  UserModel? _currentUser;
  List<UserModel> _favoriteReaders = [];
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
    
    _loadFavoriteReaders();
    _starsController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteReaders() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser == null) {
        setState(() {
          _errorMessage = 'Please log in to view your favorite readers';
          _isLoading = false;
        });
        return;
      }

      // Load user\'s favorite readers
      final favorites = await EnhancedAuthService.getFavoriteReaders(_currentUser!.id);
      
      setState(() {
        _favoriteReaders = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load favorite readers: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(UserModel reader) async {
    try {
      await EnhancedAuthService.removeFavoriteReader(_currentUser!.id, reader.id);
      
      setState(() {
        _favoriteReaders.removeWhere((r) => r.id == reader.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reader.fullName} removed from favorites'),
          backgroundColor: SoulSeerColors.mysticalPink,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove favorite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
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
                    : _buildFavoritesList(),
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
                  _loadFavoriteReaders();
                },
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    final theme = Theme.of(context);
    
    if (_favoriteReaders.isEmpty) {
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
                  Icons.favorite_border,
                  size: 80,
                  color: SoulSeerColors.mysticalPink,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Favorites Yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover amazing readers and add them to your favorites for quick access.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                MysticalButton(
                  text: 'Explore Readers',
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to explore page
                  },
                  icon: Icons.explore,
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
        itemCount: _favoriteReaders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderSection();
          }
          
          final reader = _favoriteReaders[index - 1];
          return _buildReaderCard(reader);
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
                Icons.favorite,
                color: SoulSeerColors.mysticalPink,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Favorite Readers',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your trusted spiritual advisors for instant connection',
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
                  '${_favoriteReaders.length} Favorite${_favoriteReaders.length != 1 ? 's' : ''}',
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

  Widget _buildReaderCard(UserModel reader) {
    final theme = Theme.of(context);
    
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
          onTap: () => _navigateToReaderDetail(reader),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: reader.avatarUrl != null
                              ? NetworkImage(reader.avatarUrl!)
                              : NetworkImage("https://pixabay.com/get/g7afb779e9227ef07f51e1199c07a469b661a07710f0d3a69c9d0829a8bb3a74dd9a61173f0d22aae0fa618889945a0efcc91cb6a8f884e30828e97c75b672c5b_1280.jpg"),
                        ),
                        if (reader.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reader.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (reader.readerProfile?.tagline != null)
                            Text(
                              reader.readerProfile!.tagline!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: SoulSeerColors.cosmicGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reader.readerProfile?.formattedRating ?? '0.0',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: SoulSeerColors.cosmicGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${reader.readerProfile?.totalReviews ?? 0} reviews)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: () => _showRemoveFavoriteDialog(reader),
                      tooltip: 'Remove from favorites',
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Specializations
                if (reader.readerProfile?.specializations != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reader.readerProfile!.specializations!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Pricing and availability
                Row(
                  children: [
                    if (reader.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Offline',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      'From \$${reader.readerProfile?.chatRate?.toStringAsFixed(2) ?? '0.00'}/min',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: SoulSeerColors.cosmicGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: MysticalButton(
                        text: 'View Profile',
                        onPressed: () => _navigateToReaderDetail(reader),
                        icon: Icons.person,
                        isSecondary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MysticalButton(
                        text: reader.isOnline ? 'Connect Now' : 'Message',
                        onPressed: reader.isOnline 
                            ? () => _connectWithReader(reader)
                            : () => _messageReader(reader),
                        icon: reader.isOnline ? Icons.videocam : Icons.message,
                      ),
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

  void _navigateToReaderDetail(UserModel reader) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderDetailPage(reader: reader),
      ),
    );
  }

  void _connectWithReader(UserModel reader) {
    // TODO: Implement connect with reader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting with ${reader.fullName}...'),
        backgroundColor: SoulSeerColors.mysticalPink,
      ),
    );
  }

  void _messageReader(UserModel reader) {
    // TODO: Implement message reader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Messaging ${reader.fullName}...'),
        backgroundColor: SoulSeerColors.mysticalPink,
      ),
    );
  }

  void _showRemoveFavoriteDialog(UserModel reader) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Remove Favorite?',
          style: TextStyle(
            color: SoulSeerColors.mysticalPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Remove ${reader.fullName} from your favorites?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(reader);
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}