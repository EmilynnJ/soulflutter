import 'package:flutter/material.dart';
import '../utils/soul_seer_colors.dart';
import '../pages/auth_page.dart';
import '../widgets/mystical_button.dart';

class LoginRequiredOverlay {
  static void show({
    required BuildContext context,
    required String feature,
    String? customMessage,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LoginRequiredBottomSheet(
        feature: feature,
        customMessage: customMessage,
      ),
    );
  }
}

class LoginRequiredBottomSheet extends StatefulWidget {
  final String feature;
  final String? customMessage;

  const LoginRequiredBottomSheet({
    super.key,
    required this.feature,
    this.customMessage,
  });

  @override
  State<LoginRequiredBottomSheet> createState() => _LoginRequiredBottomSheetState();
}

class _LoginRequiredBottomSheetState extends State<LoginRequiredBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: screenHeight * 0.6,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF000000),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: SoulSeerColors.mysticalPink.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Icon with mystical glow effect
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              SoulSeerColors.mysticalPink.withOpacity(0.3),
                              SoulSeerColors.cosmicGold.withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 50,
                            color: SoulSeerColors.mysticalPink,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Unlock Your Spiritual Journey',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: SoulSeerColors.mysticalPink,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Message
                      Text(
                        widget.customMessage ?? 
                        'Sign in to ${widget.feature} and connect with our gifted spiritual advisors for personalized guidance and insights.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Benefits section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SoulSeerColors.cosmicGold.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'With SoulSeer you can:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: SoulSeerColors.cosmicGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBenefitItem('🔮', 'Get personalized spiritual readings'),
                            _buildBenefitItem('💫', 'Connect with expert advisors'),
                            _buildBenefitItem('🌟', 'Save your favorite readers'),
                            _buildBenefitItem('💬', 'Chat, call, or video sessions'),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: MysticalButton(
                              text: 'Sign In',
                              onPressed: _navigateToSignIn,
                              icon: Icons.login,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: MysticalButton(
                              text: 'Create Account',
                              onPressed: _navigateToSignUp,
                              icon: Icons.person_add,
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSignIn() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthPage(initialLogin: true),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthPage(initialLogin: false),
      ),
    );
  }
}

// The AuthPage constructor is already updated to support initialLogin parameter