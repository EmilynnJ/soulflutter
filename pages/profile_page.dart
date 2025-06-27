import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/mystical_button.dart';
import '../image_upload.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _taglineController = TextEditingController();
  final _chatRateController = TextEditingController();
  final _phoneRateController = TextEditingController();
  final _videoRateController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await AuthService.getCurrentUserProfile();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _populateControllers();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load profile data');
      }
    }
  }

  void _populateControllers() {
    if (_currentUser == null) return;
    
    _fullNameController.text = _currentUser!.fullName;
    _usernameController.text = _currentUser!.username ?? '';
    _bioController.text = _currentUser!.bio ?? '';
    
    if (_currentUser!.readerProfile != null) {
      final profile = _currentUser!.readerProfile!;
      _specializationsController.text = profile.specializations;
      _taglineController.text = profile.tagline ?? '';
      _chatRateController.text = profile.chatRate.toString();
      _phoneRateController.text = profile.phoneRate.toString();
      _videoRateController.text = profile.videoRate.toString();
      _yearsExperienceController.text = profile.yearsExperience.toString();
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    
    try {
      setState(() {
        _isSaving = true;
      });

      // Update basic profile
      final updatedUser = await AuthService.updateProfile(
        userId: _currentUser!.id,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      // Update reader profile if user is a reader
      if (_currentUser!.isReader) {
        await AuthService.updateReaderProfile(
          userId: _currentUser!.id,
          specializations: _specializationsController.text.trim(),
          tagline: _taglineController.text.trim(),
          chatRate: double.tryParse(_chatRateController.text) ?? 0.0,
          phoneRate: double.tryParse(_phoneRateController.text) ?? 0.0,
          videoRate: double.tryParse(_videoRateController.text) ?? 0.0,
          yearsExperience: int.tryParse(_yearsExperienceController.text) ?? 0,
        );
      }

      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
          _isSaving = false;
        });
        
        _showSuccessSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showErrorSnackBar('Failed to update profile');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign out');
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0033),
        title: Text(
          'Sign Out',
          style: TextStyle(color: SoulSeerColors.mysticalPink),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: Text('Sign Out', style: TextStyle(color: SoulSeerColors.mysticalPink)),
          ),
        ],
      ),
    );
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
                      Expanded(
                        child: _isLoading
                            ? _buildLoadingState(theme)
                            : _buildProfileContent(theme),
                      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
          
          Row(
            children: [
              if (_currentUser != null) ...[
                MysticalIconButton(
                  icon: _isEditing ? Icons.close : Icons.edit,
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        _populateControllers(); // Reset changes
                      }
                    });
                  },
                  color: SoulSeerColors.cosmicGold,
                ),
                const SizedBox(width: 8),
                MysticalIconButton(
                  icon: Icons.logout,
                  onPressed: _showSignOutDialog,
                  color: Colors.red,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: SoulSeerColors.mysticalPink,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your profile...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ThemeData theme) {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Profile not found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            MysticalButton(
              text: 'Retry',
              onPressed: _loadUserData,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildProfileHeader(theme),
          const SizedBox(height: 24),
          _buildBasicInfoSection(theme),
          if (_currentUser!.isReader) ...[
            const SizedBox(height: 24),
            _buildReaderInfoSection(theme),
          ],
          const SizedBox(height: 24),
          _buildStatsSection(theme),
          if (_isEditing) ...[
            const SizedBox(height: 32),
            _buildSaveButton(theme),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: SoulSeerColors.mysticalGradient.scale(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: SoulSeerColors.mysticalPink,
                child: Text(
                  _currentUser!.fullName.isNotEmpty 
                      ? _currentUser!.fullName[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement avatar upload
                      _showErrorSnackBar('Avatar upload coming soon!');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SoulSeerColors.cosmicGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            _currentUser!.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          if (_currentUser!.username?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              '@${_currentUser!.username}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SoulSeerColors.cosmicGold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SoulSeerColors.cosmicGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: SoulSeerColors.cosmicGold,
                width: 1,
              ),
            ),
            child: Text(
              _currentUser!.role.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: SoulSeerColors.cosmicGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: theme.textTheme.titleLarge?.copyWith(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Full Name',
            _fullNameController,
            Icons.person,
            theme,
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Username',
            _usernameController,
            Icons.alternate_email,
            theme,
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Email',
            TextEditingController(text: _currentUser!.email),
            Icons.email,
            theme,
            isReadOnly: true,
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Bio',
            _bioController,
            Icons.description,
            theme,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildReaderInfoSection(ThemeData theme) {
    final profile = _currentUser!.readerProfile;
    if (profile == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reader Information',
            style: theme.textTheme.titleLarge?.copyWith(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Specializations',
            _specializationsController,
            Icons.auto_awesome,
            theme,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          _buildInfoField(
            'Tagline',
            _taglineController,
            Icons.format_quote,
            theme,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  'Chat Rate (\$/min)',
                  _chatRateController,
                  Icons.chat,
                  theme,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoField(
                  'Phone Rate (\$/min)',
                  _phoneRateController,
                  Icons.phone,
                  theme,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  'Video Rate (\$/min)',
                  _videoRateController,
                  Icons.videocam,
                  theme,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoField(
                  'Experience (years)',
                  _yearsExperienceController,
                  Icons.timeline,
                  theme,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Statistics',
            style: theme.textTheme.titleLarge?.copyWith(
              color: SoulSeerColors.mysticalPink,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Balance',
                  '\$${_currentUser!.accountBalance.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  SoulSeerColors.cosmicGold,
                ),
              ),
              const SizedBox(width: 12),
              if (_currentUser!.readerProfile != null) ...[
                Expanded(
                  child: _buildStatCard(
                    'Rating',
                    _currentUser!.readerProfile!.formattedRating,
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Readings',
                    _currentUser!.readerProfile!.totalReadings.toString(),
                    Icons.book,
                    SoulSeerColors.mysticalPink,
                  ),
                ),
              ] else
                Expanded(
                  child: _buildStatCard(
                    'Member Since',
                    _currentUser!.createdAt.year.toString(),
                    Icons.calendar_today,
                    SoulSeerColors.mysticalPink,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon,
    ThemeData theme, {
    bool isReadOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final isEnabled = _isEditing && !isReadOnly;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          decoration: BoxDecoration(
            color: isEnabled 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled 
                  ? SoulSeerColors.mysticalPink.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: isEnabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: MysticalButton(
            text: 'Cancel',
            onPressed: () {
              setState(() {
                _isEditing = false;
                _populateControllers();
              });
            },
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MysticalButton(
            text: 'Save Changes',
            onPressed: _isSaving ? null : _saveProfile,
            isLoading: _isSaving,
          ),
        ),
      ],
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