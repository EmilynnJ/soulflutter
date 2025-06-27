import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../widgets/post_card.dart';
import '../widgets/mystical_button.dart';
import '../widgets/login_required_overlay.dart';
import 'create_post_page.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> with TickerProviderStateMixin {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentOffset = 0;
  final int _pageSize = 10;
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    _loadPosts();
    _animationController.forward();
    _starsController.repeat(reverse: true);
    
    // Listen for scroll events to load more posts
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentOffset = 0;
    });
    
    try {
      final posts = await PostService.getFeedPosts(
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _posts = posts;
        _currentOffset = posts.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final newPosts = await PostService.getFeedPosts(
        limit: _pageSize,
        offset: _currentOffset,
      );
      
      setState(() {
        _posts.addAll(newPosts);
        _currentOffset += newPosts.length;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  void _createPost() {
    if (!AuthService.isLoggedIn) {
      LoginRequiredOverlay.show(
        context: context,
        feature: 'create posts and share with the community',
        customMessage: 'Join the SoulSeer community to share your spiritual insights, experiences, and connect with like-minded souls on their journey.',
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CreatePostPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ).then((_) {
        // Refresh posts when returning from create post page
        _refreshPosts();
      });
    }
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
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        expandedHeight: 120,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: ShaderMask(
                            shaderCallback: (bounds) => SoulSeerColors.mysticalGradient.createShader(bounds),
                            child: Text(
                              'Community',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _createPost,
                                icon: Icon(
                                  Icons.add,
                                  color: SoulSeerColors.mysticalPink,
                                ),
                                tooltip: 'Create Post',
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Welcome message for community
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
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: SoulSeerColors.mysticalPink,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'SoulSeer Community',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: SoulSeerColors.mysticalPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Connect with fellow spiritual seekers, share experiences, and discover insights from our community of gifted readers and clients.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (!AuthService.isLoggedIn) ...[
                                const SizedBox(height: 16),
                                MysticalButton(
                                  text: 'Join Community',
                                  onPressed: _createPost,
                                  icon: Icons.group_add,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // Loading state
                      if (_isLoading)
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: SoulSeerColors.mysticalPink,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading community posts...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // Error state
                      if (_errorMessage != null)
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  MysticalButton(
                                    text: 'Try Again',
                                    onPressed: _loadPosts,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // Empty state
                      if (!_isLoading && _errorMessage == null && _posts.isEmpty)
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: SoulSeerColors.mysticalPink.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 48,
                                      color: SoulSeerColors.mysticalPink,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No posts yet',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to share something with the community!',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  MysticalButton(
                                    text: 'Create First Post',
                                    onPressed: _createPost,
                                    icon: Icons.add,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // Posts list
                      if (!_isLoading && _errorMessage == null && _posts.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return PostCard(
                                post: _posts[index],
                                onLikeChanged: () {
                                  // Refresh the specific post
                                  _refreshPosts();
                                },
                                onDeleted: () {
                                  setState(() {
                                    _posts.removeAt(index);
                                  });
                                },
                              );
                            },
                            childCount: _posts.length,
                          ),
                        ),
                      
                      // Loading more indicator
                      if (_isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: SoulSeerColors.mysticalPink,
                              ),
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
            ),
          ],
        ),
      ),
      floatingActionButton: AuthService.isLoggedIn
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SoulSeerColors.mysticalPink.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _createPost,
                backgroundColor: SoulSeerColors.mysticalPink,
                foregroundColor: Colors.white,
                child: const Icon(Icons.edit),
              ),
            )
          : null,
    );
  }
}