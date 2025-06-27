import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';
import 'auth_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _starsController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _starsAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeInOut,
    ));
    
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animations
    _starsController.repeat(reverse: true);
    _logoController.forward();
    
    // Wait for animations and initialization
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (mounted) {
      // Always go to main navigation - it will handle auth state
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ...List.generate(100, (index) {
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
                      opacity: opacity * 0.7,
                      child: Container(
                        width: index % 4 == 0 ? 4 : 2,
                        height: index % 4 == 0 ? 4 : 2,
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
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mystical logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SoulSeerColors.mysticalGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: SoulSeerColors.mysticalPink.withOpacity(0.6),
                                  blurRadius: 40,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // App name
                          ShaderMask(
                            shaderCallback: (bounds) => SoulSeerColors.mysticalGradient.createShader(bounds),
                            child: Text(
                              'SoulSeer',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 72,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: SoulSeerColors.mysticalPink.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tagline
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: SoulSeerColors.mysticalGradient,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: SoulSeerColors.mysticalPink.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              'Connect with Gifted Psychics',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Loading indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: SoulSeerColors.mysticalPink,
                              backgroundColor: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}