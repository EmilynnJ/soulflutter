import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/enhanced_auth_service.dart';
import '../models/user_model.dart';
import 'home_page.dart';
import 'client_dashboard.dart';
import 'reader_dashboard.dart';
import '../widgets/mystical_button.dart';

class AuthPage extends StatefulWidget {
  final bool initialLogin;
  
  const AuthPage({super.key, this.initialLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.client;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late AnimationController _starsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    
    _isLogin = widget.initialLogin;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 20),
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
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserModel? user;
      
      if (_isLogin) {
        user = await EnhancedAuthService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        user = await EnhancedAuthService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
          username: _usernameController.text.trim().isEmpty 
            ? null 
            : _usernameController.text.trim(),
        );
      }

      if (user != null && mounted) {
        // Navigate based on user role
        Widget destination;
        if (user.isClient) {
          destination = const ClientDashboard();
        } else if (user.isReader) {
          destination = const ReaderDashboard();
        } else {
          destination = const HomePage(); // Admin goes to home for now
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => destination,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        
        // If it's a backend configuration issue, show a helpful message
        if (errorMsg.contains('not configured') || errorMsg.contains('SUPABASE')) {
          errorMsg = 'Demo Mode: Authentication requires backend setup.\nPlease configure Supabase credentials to enable login.';
        }
        
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SoulSeer',
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
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Welcome text
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: theme.colorScheme.primary,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isLogin ? 'Welcome Back' : 'Join SoulSeer',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLogin 
                                  ? 'Continue your spiritual journey'
                                  : 'Begin your spiritual journey',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Form fields
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Full name (signup only)
                              if (!_isLogin) ...[
                                _buildMysticalTextField(
                                  controller: _fullNameController,
                                  label: 'Full Name',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Username (signup only)
                              if (!_isLogin) ...[
                                _buildMysticalTextField(
                                  controller: _usernameController,
                                  label: 'Username (Optional)',
                                  icon: Icons.alternate_email,
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Email
                              _buildMysticalTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Password
                              _buildMysticalTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (!_isLogin && value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              
                              // Role selection (signup only)
                              if (!_isLogin) ...[
                                const SizedBox(height: 24),
                                Text(
                                  'Choose Your Path',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRoleCard(
                                        role: UserRole.client,
                                        title: 'Seeker',
                                        description: 'Find guidance',
                                        icon: Icons.search,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildRoleCard(
                                        role: UserRole.reader,
                                        title: 'Advisor',
                                        description: 'Share wisdom',
                                        icon: Icons.auto_awesome,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: MysticalButton(
                                  text: _isLogin ? 'Sign In' : 'Create Account',
                                  onPressed: _isLoading ? null : _submitForm,
                                  isLoading: _isLoading,
                                  icon: _isLogin ? Icons.login : Icons.person_add,
                                ),
                              ),
                              
                              // Error message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Toggle auth mode
                        Center(
                          child: TextButton(
                            onPressed: _toggleAuthMode,
                            child: RichText(
                              text: TextSpan(
                                text: _isLogin 
                                  ? 'New to SoulSeer? '
                                  : 'Already have an account? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Create Account' : 'Sign In',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMysticalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.1),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}