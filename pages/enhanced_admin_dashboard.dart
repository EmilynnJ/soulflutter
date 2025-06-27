import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> 
    with TickerProviderStateMixin {
  
  UserModel? _currentUser;
  bool _isLoading = true;
  List<UserModel> _allUsers = [];
  List<UserModel> _pendingReaders = [];
  Map<String, dynamic> _platformStats = {};
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAdminData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _starsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_starsController);

    _animationController.forward();
    _starsController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser?.role != UserRole.admin) {
        Navigator.pop(context);
        return;
      }

      // Load platform statistics
      await _loadPlatformStats();
      
      // Load all users
      await _loadAllUsers();
      
      // Load pending reader applications
      await _loadPendingReaders();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to load admin data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPlatformStats() async {
    // TODO: Implement actual stats loading from Supabase
    // For now, using sample data
    _platformStats = {
      'totalUsers': 1247,
      'activeReaders': 89,
      'totalSessions': 3456,
      'monthlyRevenue': 45678.90,
      'totalRevenue': 234567.89,
      'averageRating': 4.7,
      'sessionsToday': 23,
      'newUsersToday': 7,
    };
  }

  Future<void> _loadAllUsers() async {
    try {
      // TODO: Implement actual user loading from Supabase
      _allUsers = [];
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadPendingReaders() async {
    try {
      // TODO: Implement actual pending readers loading
      _pendingReaders = [];
    } catch (e) {
      print('Error loading pending readers: $e');
    }
  }

  void _showCreateReaderDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateReaderDialog(
        onReaderCreated: () {
          _loadAdminData();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://i.postimg.cc/sXdsKGTK/DALL-E-2025-06-06-14-36-29-A-vivid-ethereal-background-image-designed-for-a-psychic-reading-app.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: _isLoading 
              ? _buildLoadingState(theme)
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildHeader(theme),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsGrid(theme),
                                const SizedBox(height: 24),
                                _buildQuickActions(theme),
                                const SizedBox(height: 24),
                                _buildRecentActivity(theme),
                                const SizedBox(height: 24),
                                _buildUserManagement(theme),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(SoulSeerColors.mysticalPink),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Platform Management & Analytics',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: SoulSeerColors.mysticalGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'ADMIN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = [
      {
        'title': 'Total Users',
        'value': _platformStats['totalUsers']?.toString() ?? '0',
        'icon': Icons.people,
        'color': SoulSeerColors.mysticalPink,
      },
      {
        'title': 'Active Readers',
        'value': _platformStats['activeReaders']?.toString() ?? '0',
        'icon': Icons.auto_awesome,
        'color': SoulSeerColors.cosmicGold,
      },
      {
        'title': 'Total Sessions',
        'value': _platformStats['totalSessions']?.toString() ?? '0',
        'icon': Icons.video_call,
        'color': SoulSeerColors.deepPurple,
      },
      {
        'title': 'Monthly Revenue',
        'value': '\$${(_platformStats['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Sessions Today',
        'value': _platformStats['sessionsToday']?.toString() ?? '0',
        'icon': Icons.today,
        'color': Colors.orange,
      },
      {
        'title': 'New Users Today',
        'value': _platformStats['newUsersToday']?.toString() ?? '0',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              theme: theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MysticalButton(
                text: 'Add Reader',
                icon: Icons.person_add,
                onPressed: _showCreateReaderDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MysticalButton(
                text: 'Manage Products',
                icon: Icons.inventory,
                onPressed: () {
                  // TODO: Navigate to product management
                },
                isSecondary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MysticalButton(
                text: 'User Reports',
                icon: Icons.report,
                onPressed: () {
                  // TODO: Navigate to reports
                },
                isSecondary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MysticalButton(
                text: 'Analytics',
                icon: Icons.analytics,
                onPressed: () {
                  // TODO: Navigate to analytics
                },
                isSecondary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = [
      'New user registration: sarah.johnson@email.com',
      'Reader Luna Mystic completed 5 sessions today',
      'System maintenance scheduled for tonight',
      'New payment method added by Mike Truth',
      'Reader application pending: Crystal Oracle',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SoulSeerColors.mysticalPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: SoulSeerColors.mysticalPink,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserManagement(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Management',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full user management
              },
              child: Text(
                'View All',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SoulSeerColors.mysticalPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              if (_pendingReaders.isEmpty) 
                Text(
                  'No pending reader applications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                ..._pendingReaders.map((reader) => _buildPendingReaderItem(reader, theme)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingReaderItem(UserModel reader, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: reader.avatarUrl != null
              ? NetworkImage(reader.avatarUrl!)
              : null,
            child: reader.avatarUrl == null
              ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reader.fullName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  reader.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Approve reader
                  _showSuccess('Reader application approved');
                },
                icon: const Icon(Icons.check, color: Colors.green),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Reject reader
                  _showSuccess('Reader application rejected');
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateReaderDialog extends StatefulWidget {
  final VoidCallback onReaderCreated;

  const _CreateReaderDialog({required this.onReaderCreated});

  @override
  State<_CreateReaderDialog> createState() => _CreateReaderDialogState();
}

class _CreateReaderDialogState extends State<_CreateReaderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _taglineController = TextEditingController();
  final _chatRateController = TextEditingController(text: '2.99');
  final _phoneRateController = TextEditingController(text: '4.99');
  final _videoRateController = TextEditingController(text: '6.99');
  final _yearsExperienceController = TextEditingController(text: '0');
  
  bool _isLoading = false;

  Future<void> _createReader() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create reader account
      final reader = await EnhancedAuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: UserRole.reader,
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (reader != null) {
        // Update reader profile
        await EnhancedAuthService.updateReaderProfile(
          userId: reader.id,
          specializations: _specializationsController.text.trim(),
          chatRate: double.tryParse(_chatRateController.text) ?? 2.99,
          phoneRate: double.tryParse(_phoneRateController.text) ?? 4.99,
          videoRate: double.tryParse(_videoRateController.text) ?? 6.99,
          tagline: _taglineController.text.trim(),
          yearsExperience: int.tryParse(_yearsExperienceController.text) ?? 0,
        );

        widget.onReaderCreated();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reader account created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create reader: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Reader Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => 
                          value?.isEmpty == true ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => 
                          value?.isEmpty == true ? 'Password is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => 
                          value?.isEmpty == true ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specializationsController,
                        decoration: const InputDecoration(
                          labelText: 'Specializations',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _chatRateController,
                              decoration: const InputDecoration(
                                labelText: 'Chat Rate',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneRateController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Rate',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _videoRateController,
                              decoration: const InputDecoration(
                                labelText: 'Video Rate',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _yearsExperienceController,
                              decoration: const InputDecoration(
                                labelText: 'Years Experience',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MysticalButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MysticalButton(
                      text: 'Create Reader',
                      onPressed: _createReader,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _specializationsController.dispose();
    _taglineController.dispose();
    _chatRateController.dispose();
    _phoneRateController.dispose();
    _videoRateController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }
}