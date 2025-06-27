import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About SoulSeer',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero section
                                      Text(
                  'About SoulSeer',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Founder Image
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: SoulSeerColors.mysticalGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: const NetworkImage('https://i.postimg.cc/s2ds9RtC/FOUNDER.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mission Statement
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: SoulSeerColors.mysticalPink,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'About SoulSeer',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: SoulSeerColors.mysticalPink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'At SoulSeer, we are dedicated to providing ethical, compassionate, and judgment-free spiritual guidance. Our mission is twofold: to offer clients genuine, heart-centered readings and to uphold fair, ethical standards for our readers.\n\nFounded by psychic medium Emilynn, SoulSeer was created as a response to the corporate greed that dominates many psychic platforms. Unlike other apps, our readers keep the majority of what they earn and play an active role in shaping the platform.\n\nSoulSeer is more than just an app—it\'s a soul tribe. A community of gifted psychics united by our life\'s calling: to guide, heal, and empower those who seek clarity on their journey.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                      
                      const SizedBox(height: 32),
                      
                      // Mission section
                      Text(
                        'Our Mission ✨',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'At SoulSeer, we believe everyone deserves access to spiritual guidance and wisdom. Our platform connects seekers with authentic, experienced spiritual advisors who provide compassionate support and profound insights to help illuminate your path forward.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Features section
                      Text(
                        'What We Offer 🔮',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildFeatureCard(
                            icon: Icons.chat_bubble,
                            title: 'Live Chat Readings',
                            description: 'Connect instantly with spiritual advisors through our secure chat platform.',
                            theme: theme,
                          ),
                          _buildFeatureCard(
                            icon: Icons.phone,
                            title: 'Phone Consultations',
                            description: 'Have deeper conversations with your chosen advisor over the phone.',
                            theme: theme,
                          ),
                          _buildFeatureCard(
                            icon: Icons.videocam,
                            title: 'Video Sessions',
                            description: 'Experience face-to-face readings for the most personal connection.',
                            theme: theme,
                          ),
                          _buildFeatureCard(
                            icon: Icons.forum,
                            title: 'Community Platform',
                            description: 'Share experiences and connect with like-minded souls on your spiritual journey.',
                            theme: theme,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Services section
                      Text(
                        'Spiritual Services 🌙',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildServiceCard(
                            icon: Icons.style,
                            title: 'Tarot Reading',
                            description: 'Discover insights about your past, present, and future through the ancient art of tarot.',
                            theme: theme,
                          ),
                          _buildServiceCard(
                            icon: Icons.brightness_2,
                            title: 'Astrology',
                            description: 'Understand your cosmic blueprint and how celestial movements affect your life.',
                            theme: theme,
                          ),
                          _buildServiceCard(
                            icon: Icons.healing,
                            title: 'Energy Healing',
                            description: 'Balance your chakras and cleanse your energy field for optimal well-being.',
                            theme: theme,
                          ),
                          _buildServiceCard(
                            icon: Icons.favorite,
                            title: 'Love & Relationships',
                            description: 'Find clarity about matters of the heart and soul connections.',
                            theme: theme,
                          ),
                          _buildServiceCard(
                            icon: Icons.work,
                            title: 'Career Guidance',
                            description: 'Discover your life purpose and navigate your professional path.',
                            theme: theme,
                          ),
                          _buildServiceCard(
                            icon: Icons.psychology,
                            title: 'Mediumship',
                            description: 'Connect with loved ones who have passed to the spirit realm.',
                            theme: theme,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Contact section
                      Text(
                        'Connect With Us 💫',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.secondary.withOpacity(0.1),
                              theme.colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildContactItem(
                              icon: Icons.email,
                              label: 'support@soulseer.com',
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              icon: Icons.language,
                              label: 'www.soulseer.com',
                              theme: theme,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Available 24/7 for your spiritual journey',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Footer
                      Center(
                        child: Text(
                          'Made with ✨ for the spiritual community',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
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
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.tertiary,
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
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}