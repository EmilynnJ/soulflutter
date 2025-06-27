import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/enhanced_auth_service.dart';
import '../utils/soul_seer_colors.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'social_feed_page.dart';
import 'auth_page.dart';
import 'client_dashboard.dart';
import 'reader_dashboard.dart';
import 'enhanced_admin_dashboard.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'sessions_history_page.dart';
import 'favorites_page.dart';
import 'payment_history_page.dart';
import 'settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;
  
  late AnimationController _navController;
  late Animation<double> _navAnimation;

  final List<Widget> _guestPages = [
    const HomePage(),
    const ExplorePage(),
    const SocialFeedPage(),
    const AuthPage(),
  ];

  List<Widget> _authenticatedPages = [];

  @override
  void initState() {
    super.initState();
    
    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _navAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOut,
    ));
    
    _loadUserData();
    _navController.forward();
    
    // Listen for auth state changes
    EnhancedAuthService.userStream.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Listen to user changes
      EnhancedAuthService.userStream.listen((user) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        
        if (user != null) {
          _authenticatedPages = _buildAuthenticatedPages(user);
        }
      });
      
      // Initialize Enhanced Auth Service
      await EnhancedAuthService.initialize();
      
      // Get current user
      final user = EnhancedAuthService.currentUserProfile;
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      
      if (user != null) {
        _authenticatedPages = _buildAuthenticatedPages(user);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _buildAuthenticatedPages(UserModel? user) {
    return [
      const HomePage(),
      const ExplorePage(),
      const SocialFeedPage(),
      if (user?.isReader == true)
        const ReaderDashboard()
      else if (user?.isClient == true)
        const ClientDashboard()
      else
        const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: Center(
            child: CircularProgressIndicator(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
        ),
      );
    }

    final pages = _currentUser != null ? _authenticatedPages : _guestPages;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _navAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _navAnimation,
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black,
            ],
          ),
          border: Border(
            top: BorderSide(
              color: SoulSeerColors.mysticalPink.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explore',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Community',
                  index: 2,
                ),
                _buildNavItem(
                  icon: _currentUser?.isReader == true 
                      ? Icons.dashboard_outlined
                      : _currentUser?.isClient == true
                          ? Icons.account_circle_outlined
                          : Icons.login_outlined,
                  activeIcon: _currentUser?.isReader == true 
                      ? Icons.dashboard
                      : _currentUser?.isClient == true
                          ? Icons.account_circle
                          : Icons.login,
                  label: _currentUser?.isReader == true 
                      ? 'Dashboard'
                      : _currentUser?.isClient == true
                          ? 'Profile'
                          : 'Sign In',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: SoulSeerColors.cosmicGold,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'SoulSeer',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: SoulSeerColors.mysticalPink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: false,
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
      actions: [
        // Navigation Links
        TextButton(
          onPressed: () => setState(() => _currentIndex = 0),
          child: Text(
            'Home',
            style: TextStyle(
              color: _currentIndex == 0 ? SoulSeerColors.cosmicGold : SoulSeerColors.mysticalPink,
              fontWeight: _currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _currentIndex = 1),
          child: Text(
            'Explore',
            style: TextStyle(
              color: _currentIndex == 1 ? SoulSeerColors.cosmicGold : SoulSeerColors.mysticalPink,
              fontWeight: _currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _currentIndex = 2),
          child: Text(
            'Community',
            style: TextStyle(
              color: _currentIndex == 2 ? SoulSeerColors.cosmicGold : SoulSeerColors.mysticalPink,
              fontWeight: _currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // User Profile or Login
        if (_currentUser != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              _currentUser!.role == UserRole.admin 
                  ? Icons.admin_panel_settings
                  : _currentUser!.role == UserRole.reader
                      ? Icons.auto_fix_high
                      : Icons.person,
              color: _currentUser!.role == UserRole.admin 
                  ? SoulSeerColors.cosmicGold
                  : SoulSeerColors.mysticalPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: SoulSeerColors.mysticalPink,
              size: 24,
            ),
            color: Colors.black,
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: SoulSeerColors.mysticalPink, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentUser?.role != null) ...[
                PopupMenuItem(
                  value: 'dashboard',
                  child: Row(
                    children: [
                      Icon(Icons.dashboard, color: SoulSeerColors.mysticalPink, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _currentUser!.role == UserRole.reader ? 'Reader Dashboard' : 'My Dashboard',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'sessions',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: SoulSeerColors.cosmicGold, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'My Sessions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'favorites',
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Favorites',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'payments',
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Payment History',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
              ],
              PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info, color: SoulSeerColors.mysticalPink, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'About',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () => setState(() => _currentIndex = 3),
            icon: Icon(
              Icons.login,
              color: SoulSeerColors.mysticalPink,
              size: 20,
            ),
            label: Text(
              'Sign In',
              style: TextStyle(
                color: SoulSeerColors.mysticalPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(width: 16),
      ],
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'dashboard':
        if (_currentUser?.role == UserRole.client) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientDashboard()),
          );
        } else if (_currentUser?.role == UserRole.reader) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReaderDashboard()),
          );
        } else if (_currentUser?.role == UserRole.admin) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnhancedAdminDashboard()),
          );
        }
        break;
      case 'sessions':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SessionsHistoryPage()),
        );
        break;
      case 'favorites':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPage()),
        );
        break;
      case 'payments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentHistoryPage()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 'about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
        break;
      case 'logout':
        try {
          await EnhancedAuthService.signOut();
          setState(() {
            _currentUser = null;
            _currentIndex = 0;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        break;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? SoulSeerColors.mysticalPink.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(
                  color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive 
                    ? SoulSeerColors.mysticalPink
                    : Colors.white.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                    ? SoulSeerColors.mysticalPink
                    : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}