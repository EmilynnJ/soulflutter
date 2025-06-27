import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';
import '../widgets/login_required_overlay.dart';
import '../models/reading_session.dart';
import 'enhanced_reading_session_page.dart';


class ReaderDetailPage extends StatefulWidget {
  final UserModel reader;

  const ReaderDetailPage({
    super.key,
    required this.reader,
  });

  @override
  State<ReaderDetailPage> createState() => _ReaderDetailPageState();
}

class _ReaderDetailPageState extends State<ReaderDetailPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _starsController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  void _bookReading(String readingType) {
    if (!EnhancedAuthService.isLoggedIn) {
      LoginRequiredOverlay.show(
        context: context,
        feature: 'book a $readingType reading with ${widget.reader.fullName}',
        customMessage: 'Connect with ${widget.reader.fullName} for personalized spiritual guidance through $readingType. Sign in to book your reading and unlock your path to clarity.',
      );
    } else {
      // Navigate to reading session
      ReadingType type;
      switch (readingType.toLowerCase()) {
        case 'chat':
          type = ReadingType.chat;
          break;
        case 'phone':
          type = ReadingType.phone;
          break;
        case 'video':
          type = ReadingType.video;
          break;
        default:
          type = ReadingType.chat;
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EnhancedReadingSessionPage(
            reader: widget.reader,
            readingType: type,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.reader.readerProfile;
    
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Text('Reader profile not found'),
        ),
      );
    }

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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated stars background
            ...List.generate(80, (index) {
              return AnimatedBuilder(
                animation: _starsAnimation,
                builder: (context, child) {
                  final double opacity = (index % 3 == 0) 
                      ? _starsAnimation.value 
                      : (index % 2 == 0) 
                          ? 1 - _starsAnimation.value 
                          : 0.5;
                  
                  return Positioned(
                    left: (index * 37) % MediaQuery.of(context).size.width,
                    top: (index * 23) % MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: opacity * 0.6,
                      child: Container(
                        width: index % 4 == 0 ? 3 : 2,
                        height: index % 4 == 0 ? 3 : 2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Hero section
                    SliverAppBar(
                      expandedHeight: 400,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            // TODO: Add to favorites
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favorites feature coming soon!'),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.reader.avatarUrl ?? 
                                "https://pixabay.com/get/gf085fe3f216df38b24b585a45c747293a6bda14ac79ef150e8b49f6ee677bfa0ac937dca59c280b15d27a6767f1f2902d6b2804f1258e8ad3fcb10bc6ac8679b_1280.jpg",
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.reader.fullName,
                                          style: theme.textTheme.displaySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (widget.reader.isOnline)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'ONLINE',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: SoulSeerColors.cosmicGold,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        profile.formattedRating,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: SoulSeerColors.cosmicGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${profile.totalReviews} reviews)',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        profile.experienceText,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (profile.tagline != null && profile.tagline!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: SoulSeerColors.mysticalGradient,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        profile.tagline!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Specializations
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
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
                                  Icons.auto_awesome,
                                  color: SoulSeerColors.mysticalPink,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Specializations',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: SoulSeerColors.mysticalPink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              profile.specializations,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                            
                            if (profile.tools.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Tools & Methods:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: SoulSeerColors.mysticalPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: profile.tools.map((tool) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: SoulSeerColors.mysticalPink.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      tool,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: SoulSeerColors.mysticalPink,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Bio
                    if (widget.reader.bio != null && widget.reader.bio!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
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
                                    Icons.person_outline,
                                    color: SoulSeerColors.mysticalPink,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'About ${widget.reader.fullName.split(' ').first}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: SoulSeerColors.mysticalPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                widget.reader.bio!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Reading options
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: SoulSeerColors.mysticalGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Book Your Reading',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Choose your preferred consultation method',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Reading options
                            Column(
                              children: [
                                _buildReadingOption(
                                  context,
                                  icon: Icons.chat_bubble_outline,
                                  title: 'Chat Reading',
                                  description: 'Text-based spiritual guidance',
                                  price: '\$${profile.chatRate}/min',
                                  onTap: () => _bookReading('chat'),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildReadingOption(
                                  context,
                                  icon: Icons.phone_outlined,
                                  title: 'Phone Reading',
                                  description: 'Voice consultation and guidance',
                                  price: '\$${profile.phoneRate}/min',
                                  onTap: () => _bookReading('phone'),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildReadingOption(
                                  context,
                                  icon: Icons.videocam_outlined,
                                  title: 'Video Reading',
                                  description: 'Face-to-face spiritual session',
                                  price: '\$${profile.videoRate}/min',
                                  onTap: () => _bookReading('video'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Stats
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.star,
                              label: 'Rating',
                              value: profile.formattedRating,
                              color: SoulSeerColors.cosmicGold,
                            ),
                            _buildStatItem(
                              icon: Icons.chat,
                              label: 'Readings',
                              value: profile.totalReadings.toString(),
                              color: SoulSeerColors.mysticalPink,
                            ),
                            _buildStatItem(
                              icon: Icons.schedule,
                              label: 'Experience',
                              value: '${profile.yearsExperience} years',
                              color: SoulSeerColors.mysticalPink,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
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

  Widget _buildReadingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}