import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/reader_card.dart';
import '../widgets/mystical_button.dart';

import 'reader_detail_page.dart';
import 'explore_page.dart';
import 'social_feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  UserModel? _currentUser;
  List<UserModel> _onlineReaders = [];
  List<UserModel> _featuredReaders = [];
  bool _isLoading = true;
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    
    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_starsController);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      _currentUser = await AuthService.getCurrentUserProfile();
      _onlineReaders = await AuthService.getAvailableReaders();
      _featuredReaders = await AuthService.getTopRatedReaders(limit: 4);
    } catch (e) {
      // In production mode, load sample data
      _onlineReaders = _getSampleOnlineReaders();
      _featuredReaders = _getSampleFeaturedReaders();
    }
    
    setState(() => _isLoading = false);
  }

  List<UserModel> _getSampleOnlineReaders() {
    return [
      UserModel(
        id: '1',
        email: 'luna@soulseer.com',
        fullName: 'Luna Mystic',
        role: UserRole.reader,
        username: 'luna_mystic',
        bio: 'Tarot & Astrology Expert',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '1',
          specializations: 'Love & Relationships, Career',
          chatRate: 2.99,
          phoneRate: 4.99,
          videoRate: 6.99,
          rating: 4.8,
          totalReadings: 245,
          totalReviews: 230,
          isAvailable: true,
          tagline: 'Let the cards reveal your destiny ✨',
          tools: ['Tarot Cards', 'Astrology'],
          yearsExperience: 8,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '2',
        email: 'sage@soulseer.com',
        fullName: 'Crystal Sage',
        role: UserRole.reader,
        username: 'crystal_sage',
        bio: 'Crystal Healing & Mediumship',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '2',
          specializations: 'Energy Healing, Spirit Communication',
          chatRate: 3.49,
          phoneRate: 5.49,
          videoRate: 7.99,
          rating: 4.9,
          totalReadings: 156,
          totalReviews: 145,
          isAvailable: true,
          tagline: 'Bridging spirit and soul 🔮',
          tools: ['Crystals', 'Mediumship'],
          yearsExperience: 12,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '3',
        email: 'oracle@soulseer.com',
        fullName: 'Divine Oracle',
        role: UserRole.reader,
        username: 'divine_oracle',
        bio: 'Oracle Cards & Life Guidance',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '3',
          specializations: 'Life Purpose, Spiritual Growth',
          chatRate: 2.49,
          phoneRate: 3.99,
          videoRate: 5.99,
          rating: 4.7,
          totalReadings: 189,
          totalReviews: 175,
          isAvailable: true,
          tagline: 'Ancient wisdom for modern souls 🌙',
          tools: ['Oracle Cards', 'Meditation'],
          yearsExperience: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    ];
  }

  List<UserModel> _getSampleFeaturedReaders() {
    return _getSampleOnlineReaders().take(2).toList();
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
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: SoulSeerColors.mysticalPink,
                backgroundColor: Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Section
                          _buildHeroSection(theme),
                          
                          // Online Readers Section
                          _buildOnlineReadersSection(theme),
                          
                          // Live Streams Section
                          _buildLiveStreamsSection(theme),
                          
                          // Featured Products Section
                          _buildFeaturedProductsSection(theme),
                          
                          // Community Highlights Section
                          _buildCommunityHighlightsSection(theme),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Header
          Text(
            'SoulSeer',
            style: theme.textTheme.displayLarge?.copyWith(
              color: SoulSeerColors.mysticalPink,
              fontSize: 48,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.network(
                'https://i.postimg.cc/tRLSgCPb/HERO-IMAGE-1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: SoulSeerColors.mysticalGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tagline
          Text(
            'A Community of Gifted Psychics',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          MysticalButton(
            text: 'Find Your Reader',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExplorePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineReadersSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Online Readers',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.cosmicGold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExplorePage()),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: _isLoading
              ? _buildLoadingCards()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _onlineReaders.length,
                  itemBuilder: (context, index) {
                    final reader = _onlineReaders[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ReaderCard(
                        reader: reader,
                        isOnline: true,
                        showFullCard: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReaderDetailPage(reader: reader),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLiveStreamsSection(ThemeData theme) {
    final liveStreams = [
      {
        'title': 'Friday Night Guidance',
        'reader': 'Luna Mystic',
        'viewers': 45,
        'topic': 'Love & Relationships',
        'image': "https://pixabay.com/get/gdeb9cf5f4b06bea350ceaef016b6f62c040cd493bb32d0601df79b17c3b6e790f016e37126a7da1f9f075d38134a8b36503c373cf7344f2f363bd2ea010afbdc_1280.jpg",
      },
      {
        'title': 'Weekend Spiritual Circle',
        'reader': 'Crystal Sage',
        'viewers': 32,
        'topic': 'Energy Healing',
        'image': "https://pixabay.com/get/ga4b88a22684ac9515006c2d9bce1b4c68a311728bf559d7d3502c9192ea33248597d1851573fa8b82d66515c93ae9403b703696694e89be491fa458215b62568_1280.jpg",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Live Streams',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: SoulSeerColors.cosmicGold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: liveStreams.length,
            itemBuilder: (context, index) {
              final stream = liveStreams[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildLiveStreamCard(stream, theme),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLiveStreamCard(Map<String, dynamic> stream, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              stream['image'],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.live_tv,
                    color: Colors.white54,
                    size: 48,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 8),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${stream['viewers']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'with ${stream['reader']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SoulSeerColors.mysticalPink,
                    ),
                  ),
                  Text(
                    stream['topic'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(ThemeData theme) {
    final products = [
      {
        'name': 'Personalized Birth Chart',
        'price': '\$29.99',
        'reader': 'Luna Mystic',
        'rating': 4.9,
        'image': "https://pixabay.com/get/g19c809ea32da3256c87d0522763860f737e9e4f5ecc5e70ce07c908a880b2667952c1a337732a55382cda50d172686f7ab274fe566aba2f0524654058ca33690_1280.jpg",
      },
      {
        'name': 'Crystal Healing Kit',
        'price': '\$45.00',
        'reader': 'Crystal Sage',
        'rating': 4.8,
        'image': "https://pixabay.com/get/ga765bdb0a9360da252a52a133c320b7c9f07f21c4be985a91e23ec589b3b16cf9f8f9dbcc72503106fdf0c009fd0b58a1ca3ee688d7d0ef97ac18c99e9773ace_1280.jpg",
      },
      {
        'name': 'Meditation Guide Audio',
        'price': '\$19.99',
        'reader': 'Divine Oracle',
        'rating': 4.7,
        'image': "https://pixabay.com/get/ge566be3f238b6372884c78f72bd96e51833571206c28e8db470faaf28e46c85c247d84233668aba540db0be623db50e35de711cac2fd4668d7e02fc1910de586_1280.jpg",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Featured Products',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: SoulSeerColors.cosmicGold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildProductCard(product, theme),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product['image'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white54,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${product['reader']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SoulSeerColors.mysticalPink,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: SoulSeerColors.cosmicGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: SoulSeerColors.cosmicGold,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product['rating']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildCommunityHighlightsSection(ThemeData theme) {
    final highlights = [
      {
        'title': 'New Moon Manifestation Circle',
        'description': 'Join our community for powerful new moon intentions',
        'author': 'SoulSeer Community',
        'likes': 156,
        'comments': 23,
        'image': "https://pixabay.com/get/gd3c850b0f1bd062cc02e756c64b53ac6a257d03e5c2580182e540baa569b8b7fa9b8ae3a32ba828f7a82338a712e96a83afa4b1ded4062d93c8f2e2f5a347a40_1280.jpg",
      },
      {
        'title': 'Weekly Tarot Challenge',
        'description': 'Share your daily card pulls and connect with fellow seekers',
        'author': 'Luna Mystic',
        'likes': 89,
        'comments': 45,
        'image': "https://pixabay.com/get/g4b384125360e1b608df35ea20fc4b8e9ddd2e0b992bfbb847691dfa124f6816ebcfe67e70bdb02f4e747739ca17bad71603893bdb9edcde85539f879e68568b3_1280.jpg",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Highlights',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.cosmicGold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SocialFeedPage()),
                  );
                },
                child: Text(
                  'Join Community',
                  style: TextStyle(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...highlights.map((highlight) => _buildCommunityCard(highlight, theme)),
      ],
    );
  }

  Widget _buildCommunityCard(Map<String, dynamic> highlight, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              highlight['image'],
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.group,
                    color: Colors.white54,
                    size: 48,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  highlight['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'by ${highlight['author']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SoulSeerColors.mysticalPink,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: SoulSeerColors.mysticalPink,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${highlight['likes']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.comment,
                          color: SoulSeerColors.cosmicGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${highlight['comments']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 240,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[900],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
        );
      },
    );
  }
}