import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/mystical_button.dart';
import 'profile_page.dart';

class ReaderDashboard extends StatefulWidget {
  const ReaderDashboard({super.key});

  @override
  State<ReaderDashboard> createState() => _ReaderDashboardState();
}

class _ReaderDashboardState extends State<ReaderDashboard> with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isAvailable = false;
  
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
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isAvailable = user?.readerProfile?.isAvailable ?? false;
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

  Future<void> _toggleAvailability() async {
    if (_currentUser?.readerProfile == null) return;
    
    try {
      final newStatus = !_isAvailable;
      
      await AuthService.updateReaderProfile(
        userId: _currentUser!.id,
        isAvailable: newStatus,
      );
      
      await AuthService.updateOnlineStatus(newStatus);
      
      setState(() {
        _isAvailable = newStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'You are now available for readings' : 'You are now offline',
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${AuthService.getErrorMessage(e)}'),
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
    
    final profile = _currentUser?.readerProfile;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reader Dashboard',
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
                      // Profile section
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
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: _currentUser?.avatarUrl != null
                                          ? NetworkImage(_currentUser!.avatarUrl!)
                                          : null,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      child: _currentUser?.avatarUrl == null
                                          ? Icon(
                                              Icons.person,
                                              color: theme.colorScheme.primary,
                                              size: 35,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: _isAvailable ? Colors.green : Colors.grey,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 3,
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
                                        _currentUser?.fullName ?? 'Spiritual Advisor',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      if (profile?.tagline != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          profile!.tagline!,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _isAvailable 
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _isAvailable ? 'Available' : 'Offline',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: _isAvailable ? Colors.green : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          MysticalButton(
                                            text: _isAvailable ? 'Go Offline' : 'Go Online',
                                            onPressed: _toggleAvailability,
                                            icon: _isAvailable ? Icons.pause : Icons.play_arrow,
                                            isSecondary: !_isAvailable,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Stats section
                      if (profile != null) ...[
                        Text(
                          'Your Performance 📊',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.star,
                                label: 'Rating',
                                value: profile.formattedRating,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.book,
                                label: 'Readings',
                                value: '${profile.totalReadings}',
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.monetization_on,
                                label: 'Total Earned',
                                value: '\$${profile.totalEarnings.toStringAsFixed(0)}',
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.pending,
                                label: 'Pending',
                                value: '\$${profile.pendingEarnings.toStringAsFixed(2)}',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                      
                      // Quick actions
                      Text(
                        'Quick Actions ⚡',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildActionCard(
                            icon: Icons.settings,
                            title: 'Update Rates',
                            description: 'Modify your per-minute pricing',
                            onTap: _showRatesDialog,
                          ),
                          _buildActionCard(
                            icon: Icons.schedule,
                            title: 'Manage Schedule',
                            description: 'Set your availability hours',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon!')),
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.chat,
                            title: 'Active Sessions',
                            description: 'View ongoing client sessions',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon!')),
                              );
                            },
                          ),
                          _buildActionCard(
                            icon: Icons.analytics,
                            title: 'View Analytics',
                            description: 'Track your performance metrics',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon!')),
                              );
                            },
                          ),
                        ],
                      ),
                      
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatesDialog() {
    final theme = Theme.of(context);
    final profile = _currentUser?.readerProfile;
    
    if (profile == null) return;
    
    final chatController = TextEditingController(text: profile.chatRate.toStringAsFixed(2));
    final phoneController = TextEditingController(text: profile.phoneRate.toStringAsFixed(2));
    final videoController = TextEditingController(text: profile.videoRate.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Update Your Rates',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set your per-minute rates for different reading types:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildRateField(
                controller: chatController,
                label: 'Chat Rate (per minute)',
                icon: Icons.chat,
              ),
              const SizedBox(height: 12),
              _buildRateField(
                controller: phoneController,
                label: 'Phone Rate (per minute)',
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              _buildRateField(
                controller: videoController,
                label: 'Video Rate (per minute)',
                icon: Icons.videocam,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          MysticalButton(
            text: 'Update Rates',
            onPressed: () async {
              final chatRate = double.tryParse(chatController.text);
              final phoneRate = double.tryParse(phoneController.text);
              final videoRate = double.tryParse(videoController.text);
              
              if (chatRate != null && phoneRate != null && videoRate != null) {
                try {
                  await AuthService.updateReaderProfile(
                    userId: _currentUser!.id,
                    chatRate: chatRate,
                    phoneRate: phoneRate,
                    videoRate: videoRate,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rates updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUserData(); // Refresh data
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update rates: ${AuthService.getErrorMessage(e)}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid rates'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icons.save,
          ),
        ],
      ),
    );
  }

  Widget _buildRateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        prefixText: '\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}