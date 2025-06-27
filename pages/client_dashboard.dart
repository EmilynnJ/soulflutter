import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/mystical_button.dart';
import 'explore_page.dart';
import 'profile_page.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  List<UserModel> _favoriteReaders = [];
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

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

    _starsController.repeat();
    _animationController.forward();
    
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      
      final user = await AuthService.getCurrentUserProfile();
      final readers = await AuthService.getTopRatedReaders(limit: 3);
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _favoriteReaders = readers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${AuthService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Dashboard',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.primary),
            onPressed: () async {
              await AuthService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
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
            ...List.generate(80, (index) {
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
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: _currentUser?.avatarUrl != null
                                      ? NetworkImage(_currentUser!.avatarUrl!)
                                      : null,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  child: _currentUser?.avatarUrl == null
                                      ? Icon(
                                          Icons.person,
                                          color: theme.colorScheme.primary,
                                          size: 30,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${_currentUser?.fullName ?? 'Soul Seeker'}',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Your spiritual journey continues...',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: theme.colorScheme.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Account Balance',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                      Text(
                                        '\$${_currentUser?.accountBalance.toStringAsFixed(2) ?? '0.00'}',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  MysticalButton(
                                    text: 'Add Funds',
                                    onPressed: _showAddFundsDialog,
                                    icon: Icons.add,
                                    isSecondary: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Quick actions
                      Text(
                        'Quick Actions ⚡',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.search,
                              title: 'Find Readers',
                              description: 'Browse our talented spiritual advisors',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ExplorePage()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.history,
                              title: 'My Sessions',
                              description: 'View your reading history',
                              onTap: () {
                                // TODO: Navigate to sessions page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.favorite,
                              title: 'Favorites',
                              description: 'Your saved readers',
                              onTap: () {
                                // TODO: Navigate to favorites page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.forum,
                              title: 'Community',
                              description: 'Connect with others',
                              onTap: () {
                                // TODO: Navigate to community page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Recommended readers
                      if (_favoriteReaders.isNotEmpty) ...[
                        Text(
                          'Recommended for You 🌟',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _favoriteReaders.length,
                            itemBuilder: (context, index) {
                              final reader = _favoriteReaders[index];
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: reader.avatarUrl != null
                                              ? NetworkImage(reader.avatarUrl!)
                                              : null,
                                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                          child: reader.avatarUrl == null
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
                                                reader.fullName,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (reader.readerProfile?.tagline != null)
                                                Text(
                                                  reader.readerProfile!.tagline!,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (reader.readerProfile != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: theme.colorScheme.secondary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                reader.readerProfile!.formattedRating,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.secondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (reader.readerProfile?.specializations != null)
                                      Text(
                                        reader.readerProfile!.specializations,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const Spacer(),
                                    MysticalButton(
                                      text: 'Connect Now',
                                      onPressed: () {
                                        // TODO: Navigate to reader detail page
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Coming soon!')),
                                        );
                                      },
                                      icon: Icons.chat,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.tertiary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog() {
    final theme = Theme.of(context);
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Add Funds',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the amount you\'d like to add to your account:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MysticalButton(
                    text: '\$10',
                    onPressed: () => amountController.text = '10',
                    isSecondary: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MysticalButton(
                    text: '\$25',
                    onPressed: () => amountController.text = '25',
                    isSecondary: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MysticalButton(
                    text: '\$50',
                    onPressed: () => amountController.text = '50',
                    isSecondary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          MysticalButton(
            text: 'Add Funds',
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                // TODO: Implement payment processing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment processing coming soon! Would add \$${amount.toStringAsFixed(2)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icons.payment,
          ),
        ],
      ),
    );
  }
}