import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/reader_card.dart';
import '../widgets/mystical_button.dart';
import 'reader_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allReaders = [];
  List<UserModel> _filteredReaders = [];
  List<String> _selectedCategories = [];
  String _sortBy = 'rating';
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  final List<String> _categories = [
    'Love & Relationships',
    'Career Guidance', 
    'Life Purpose',
    'Mediumship',
    'Energy Healing',
    'Astrology',
    'Tarot Reading',
    'Oracle Reading',
    'Crystal Healing',
    'Chakra Balancing',
    'Past Life',
    'Spirit Communication'
  ];

  final List<String> _sortOptions = [
    'rating',
    'price_low',
    'price_high',
    'experience',
    'reviews'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadReaders();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReaders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final readers = await AuthService.getAvailableReaders();
        
        setState(() {
          _allReaders = readers;
          _filteredReaders = readers;
          _isLoading = false;
        });
      } catch (e) {
        // Provide sample data for demo
        final sampleReaders = _getSampleReaders();
        setState(() {
          _allReaders = sampleReaders;
          _filteredReaders = sampleReaders;
          _isLoading = false;
        });
      }
      
      _applyFilters();
    } catch (e) {
      final sampleReaders = _getSampleReaders();
      setState(() {
        _allReaders = sampleReaders;
        _filteredReaders = sampleReaders;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(_allReaders);
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((reader) {
        return reader.fullName.toLowerCase().contains(query) ||
               reader.username?.toLowerCase().contains(query) == true ||
               reader.readerProfile?.specializations.toLowerCase().contains(query) == true ||
               reader.readerProfile?.tagline?.toLowerCase().contains(query) == true;
      }).toList();
    }
    
    // Apply category filters
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((reader) {
        final specializations = reader.readerProfile?.specializations.toLowerCase() ?? '';
        return _selectedCategories.any((category) => 
          specializations.contains(category.toLowerCase()));
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return (b.readerProfile?.rating ?? 0).compareTo(a.readerProfile?.rating ?? 0);
        case 'price_low':
          return (a.readerProfile?.chatRate ?? 0).compareTo(b.readerProfile?.chatRate ?? 0);
        case 'price_high':
          return (b.readerProfile?.chatRate ?? 0).compareTo(a.readerProfile?.chatRate ?? 0);
        case 'experience':
          return (b.readerProfile?.yearsExperience ?? 0).compareTo(a.readerProfile?.yearsExperience ?? 0);
        case 'reviews':
          return (b.readerProfile?.totalReviews ?? 0).compareTo(a.readerProfile?.totalReviews ?? 0);
        default:
          return 0;
      }
    });
    
    setState(() {
      _filteredReaders = filtered;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _applyFilters();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersBottomSheet(),
    );
  }

  Widget _buildFiltersBottomSheet() {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: SoulSeerColors.mysticalGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters & Sort',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((option) {
                      final isSelected = _sortBy == option;
                      return ChoiceChip(
                        label: Text(_getSortLabel(option)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _sortBy = option;
                          });
                          _applyFilters();
                        },
                        selectedColor: SoulSeerColors.cosmicGold,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Specializations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) => _toggleCategory(category),
                        selectedColor: SoulSeerColors.cosmicGold,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MysticalButton(
                    text: 'Clear All',
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                        _sortBy = 'rating';
                      });
                      _applyFilters();
                      Navigator.of(context).pop();
                    },
                    isSecondary: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MysticalButton(
                    text: 'Apply',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortOption) {
    switch (sortOption) {
      case 'rating':
        return 'Highest Rated';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'experience':
        return 'Most Experienced';
      case 'reviews':
        return 'Most Reviews';
      default:
        return sortOption;
    }
  }

  List<UserModel> _getSampleReaders() {
    return [
      UserModel(
        id: '1',
        email: 'luna@example.com',
        fullName: 'Luna Mystic',
        role: UserRole.reader,
        username: 'mystic_luna',
        bio: 'Experienced tarot reader with 10+ years of spiritual guidance. Specializing in love, career, and life purpose readings.',
        isOnline: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '1',
          specializations: 'Love & Relationships, Career Guidance, Life Purpose',
          chatRate: 2.99,
          phoneRate: 4.99,
          videoRate: 6.99,
          rating: 4.8,
          totalReadings: 156,
          totalReviews: 142,
          isAvailable: true,
          tagline: 'Let the cards reveal your destiny ✨',
          tools: ['Tarot Cards', 'Oracle Cards', 'Numerology'],
          yearsExperience: 12,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '2',
        email: 'sage@example.com',
        fullName: 'Cosmic Sage',
        role: UserRole.reader,
        username: 'cosmic_sage',
        bio: 'Psychic medium connecting with spirit guides and passed loved ones. Crystal healing and chakra balancing expert.',
        isOnline: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '2',
          specializations: 'Mediumship, Energy Healing, Spirit Communication',
          chatRate: 3.49,
          phoneRate: 5.49,
          videoRate: 7.99,
          rating: 4.9,
          totalReadings: 89,
          totalReviews: 81,
          isAvailable: true,
          tagline: 'Bridging worlds between spirit and soul 🔮',
          tools: ['Crystals', 'Chakra Healing', 'Spirit Communication'],
          yearsExperience: 8,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '3',
        email: 'oracle@example.com',
        fullName: 'Crystal Oracle',
        role: UserRole.reader,
        username: 'crystal_oracle',
        bio: 'Oracle card reader and astrologer. Helping souls find their path through ancient wisdom and celestial guidance.',
        isOnline: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '3',
          specializations: 'Astrology, Oracle Reading, Past Life',
          chatRate: 2.49,
          phoneRate: 3.99,
          videoRate: 5.99,
          rating: 4.6,
          totalReadings: 203,
          totalReviews: 187,
          isAvailable: false,
          tagline: 'Ancient wisdom for modern souls 🌙',
          tools: ['Oracle Cards', 'Astrology', 'Crystal Ball'],
          yearsExperience: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '4',
        email: 'spiritual@example.com',
        fullName: 'Serene Spirit',
        role: UserRole.reader,
        username: 'serene_spirit',
        bio: 'Energy healer and spiritual counselor specializing in chakra alignment and aura cleansing.',
        isOnline: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '4',
          specializations: 'Energy Healing, Chakra Balancing, Aura Reading',
          chatRate: 3.99,
          phoneRate: 6.49,
          videoRate: 8.99,
          rating: 4.7,
          totalReadings: 134,
          totalReviews: 128,
          isAvailable: true,
          tagline: 'Healing your energy, transforming your life ✨',
          tools: ['Energy Healing', 'Chakra Stones', 'Meditation'],
          yearsExperience: 7,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: '5',
        email: 'mystic@example.com',
        fullName: 'Divine Mystic',
        role: UserRole.reader,
        username: 'divine_mystic',
        bio: 'Twin flame specialist and love psychic helping souls find their divine connections.',
        isOnline: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: '5',
          specializations: 'Love & Relationships, Twin Flame, Soulmate',
          chatRate: 4.49,
          phoneRate: 7.99,
          videoRate: 9.99,
          rating: 4.9,
          totalReadings: 267,
          totalReviews: 251,
          isAvailable: true,
          tagline: 'Connecting hearts across dimensions 💕',
          tools: ['Love Tarot', 'Twin Flame Oracle', 'Heart Chakra'],
          yearsExperience: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    ];
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
                      _buildSearchBar(theme),
                      if (_selectedCategories.isNotEmpty) _buildActiveFilters(theme),
                      Expanded(child: _buildReadersList(theme)),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Readers',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your perfect spiritual guide',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          MysticalIconButton(
            icon: Icons.tune,
            onPressed: _showFilters,
            color: SoulSeerColors.cosmicGold,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search readers, specializations...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
        ),
        onChanged: (_) => _applyFilters(),
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 20, top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedCategories.length,
        itemBuilder: (context, index) {
          final category = _selectedCategories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                category,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              backgroundColor: SoulSeerColors.cosmicGold,
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
              onDeleted: () => _toggleCategory(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadersList(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: SoulSeerColors.mysticalPink,
            ),
            const SizedBox(height: 16),
            Text(
              'Finding your perfect readers...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MysticalButton(
              text: 'Retry',
              onPressed: _loadReaders,
            ),
          ],
        ),
      );
    }

    if (_filteredReaders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No readers found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            MysticalButton(
              text: 'Clear Filters',
              onPressed: () {
                setState(() {
                  _selectedCategories.clear();
                  _searchController.clear();
                  _sortBy = 'rating';
                });
                _applyFilters();
              },
              isSecondary: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReaders,
      color: SoulSeerColors.mysticalPink,
      backgroundColor: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredReaders.length,
        itemBuilder: (context, index) {
          final reader = _filteredReaders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ReaderCard(
              reader: reader,
              isOnline: reader.isOnline,
              showFullCard: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReaderDetailPage(reader: reader),
                  ),
                );
              },
            ),
          );
        },
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