import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';
import '../utils/soul_seer_colors.dart';
import 'dart:math' as math;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationsEnabled = true;
  bool _darkMode = false;
  String _language = 'English';
  String _currency = 'USD';
  
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
    
    _loadUserSettings();
    _starsController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser == null) {
        Navigator.pop(context);
        return;
      }

      // Load user preferences from storage or database
      // For now, using default values
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    // TODO: Implement settings saving to database/storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: SoulSeerColors.mysticalPink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: SoulSeerColors.cosmicGold,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                : _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildAppearanceSettings(),
          const SizedBox(height: 24),
          _buildPreferencesSettings(),
          const SizedBox(height: 24),
          _buildAccountSettings(),
          const SizedBox(height: 24),
          _buildSupportSettings(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    
    return Container(
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
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: SoulSeerColors.mysticalPink,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Customize your spiritual journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Enable Notifications',
          subtitle: 'Receive notifications about readings and messages',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) {
                _emailNotifications = false;
                _pushNotifications = false;
              }
            });
          },
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Get updates via email',
          value: _emailNotifications && _notificationsEnabled,
          onChanged: _notificationsEnabled
              ? (value) => setState(() => _emailNotifications = value)
              : null,
        ),
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Instant alerts on your device',
          value: _pushNotifications && _notificationsEnabled,
          onChanged: _notificationsEnabled
              ? (value) => setState(() => _pushNotifications = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Use dark theme throughout the app',
          value: _darkMode,
          onChanged: (value) => setState(() => _darkMode = value),
        ),
        _buildSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Play sounds for interactions',
          value: _soundEnabled,
          onChanged: (value) => setState(() => _soundEnabled = value),
        ),
        _buildSwitchTile(
          title: 'Vibrations',
          subtitle: 'Haptic feedback for notifications',
          value: _vibrationsEnabled,
          onChanged: (value) => setState(() => _vibrationsEnabled = value),
        ),
      ],
    );
  }

  Widget _buildPreferencesSettings() {
    return _buildSettingsSection(
      title: 'Preferences',
      icon: Icons.tune,
      children: [
        _buildDropdownTile(
          title: 'Language',
          subtitle: 'Choose your preferred language',
          value: _language,
          options: ['English', 'Spanish', 'French', 'German', 'Italian'],
          onChanged: (value) => setState(() => _language = value!),
        ),
        _buildDropdownTile(
          title: 'Currency',
          subtitle: 'Display prices in your currency',
          value: _currency,
          options: ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
          onChanged: (value) => setState(() => _currency = value!),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        _buildActionTile(
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: Icons.lock,
          onTap: _showChangePasswordDialog,
        ),
        _buildActionTile(
          title: 'Privacy Settings',
          subtitle: 'Manage your privacy preferences',
          icon: Icons.privacy_tip,
          onTap: _showPrivacySettings,
        ),
        _buildActionTile(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          icon: Icons.delete_forever,
          onTap: _showDeleteAccountDialog,
          destructive: true,
        ),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return _buildSettingsSection(
      title: 'Support',
      icon: Icons.help,
      children: [
        _buildActionTile(
          title: 'Help Center',
          subtitle: 'Find answers to common questions',
          icon: Icons.help_center,
          onTap: () => _showInfo('Help Center feature coming soon!'),
        ),
        _buildActionTile(
          title: 'Contact Support',
          subtitle: 'Get help from our support team',
          icon: Icons.support_agent,
          onTap: () => _showInfo('Contact support feature coming soon!'),
        ),
        _buildActionTile(
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          icon: Icons.description,
          onTap: () => _showInfo('Terms of Service coming soon!'),
        ),
        _buildActionTile(
          title: 'Privacy Policy',
          subtitle: 'Learn about our privacy practices',
          icon: Icons.policy,
          onTap: () => _showInfo('Privacy Policy coming soon!'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SoulSeerColors.mysticalPink.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: SoulSeerColors.mysticalPink,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: SoulSeerColors.mysticalPink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: theme.colorScheme.surface,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: SoulSeerColors.mysticalPink,
          ),
          underline: Container(),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: destructive ? Colors.red : SoulSeerColors.mysticalPink,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: destructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Change Password',
          style: TextStyle(
            color: SoulSeerColors.mysticalPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Password change feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: SoulSeerColors.mysticalPink),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    _showInfo('Privacy settings feature coming soon!');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
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
              _showInfo('Account deletion feature coming soon!');
            },
            child: const Text(
              'Delete',
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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SoulSeerColors.mysticalPink,
      ),
    );
  }
}