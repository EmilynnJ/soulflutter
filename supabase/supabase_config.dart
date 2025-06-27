import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ljhjtwrdqcctwofrcwxp.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqaGp0d3JkcWNjdHdvZnJjd3hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MjIwNTIsImV4cCI6MjA2NDI5ODA1Mn0.jakcVchvXgYtqaMzAldCH70RQNrdKpwdlv9SSOGvX_U';
  
  static bool _isInitialized = false;
  
  static SupabaseClient? get client {
    if (!_isInitialized) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> initialize() async {
    try {
      // For demo purposes, always run in demo mode
      print('Running in demo mode - Supabase features disabled');
      _isInitialized = false;
      
      // Uncomment the following lines and replace with your actual Supabase credentials
      // await Supabase.initialize(
      //   url: 'https://ljhjtwrdqcctwofrcwxp.supabase.co',
      //   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqaGp0d3JkcWNjdHdvZnJjd3hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MjIwNTIsImV4cCI6MjA2NDI5ODA1Mn0.jakcVchvXgYtqaMzAldCH70RQNrdKpwdlv9SSOGvX_U',
      // );
      // _isInitialized = true;
    } catch (e) {
      print('Supabase initialization failed: $e');
      _isInitialized = false;
    }
  }
  
  // Authentication helpers
  static User? get currentUser => client?.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static bool get isDemoMode => !_isInitialized;
  
  // Sign up with role
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'client', 'reader', or 'admin'
    String? username,
  }) async {
    if (client == null) {
      throw Exception('Authentication service is not available. Please configure Supabase credentials.');
    }
    
    try {
      final response = await client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
          'username': username,
        },
      );
      
      if (response.user != null) {
        // Create user profile in users table
        await client!.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role,
          'username': username,
          'account_balance': 0.0,
          'is_online': false,
        });
        
        // If registering as reader, create reader profile
        if (role == 'reader') {
          await client!.from('reader_profiles').insert({
            'user_id': response.user!.id,
            'specializations': '',
            'chat_rate': 0.0,
            'phone_rate': 0.0,
            'video_rate': 0.0,
            'is_available': false,
            'tools': [],
            'years_experience': 0,
            'total_earnings': 0.0,
            'pending_earnings': 0.0,
          });
        }
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      throw Exception('Authentication service is not available. Please configure Supabase credentials.');
    }
    
    try {
      final response = await client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Update user online status
        await client!
            .from('users')
            .update({'is_online': true})
            .eq('id', response.user!.id);
      }
      
      return response;
    } catch (e) {
      throw Exception('Sign in failed: ${getErrorMessage(e)}');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    if (client == null) return;
    
    try {
      final currentUser = client!.auth.currentUser;
      
      if (currentUser != null) {
        // Update user online status before signing out
        await client!
            .from('users')
            .update({'is_online': false})
            .eq('id', currentUser.id);
      }
      
      await client!.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  // Handle authentication state changes
  static Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;
  
  // Error handling for common Supabase errors
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'Signup disabled':
          return 'New registrations are currently disabled';
        default:
          return error.message;
      }
    } else if (error is PostgrestException) {
      if (error.code == '23505') {
        if (error.message.contains('username')) {
          return 'Username already taken';
        }
        return 'This information is already in use';
      }
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
  
  // Real-time helpers
  static RealtimeChannel? subscribeToUserStatus() {
    if (client == null) return null;
    
    return client!
        .channel('user_status')
        .onPresenceSync((payload) {
          // Handle user status updates
        })
        .onPresenceJoin((payload) {
          // Handle user coming online
        })
        .onPresenceLeave((payload) {
          // Handle user going offline
        })
        .subscribe();
  }
  
  static RealtimeChannel? subscribeToReadingSessions(String userId) {
    if (client == null) return null;
    
    return client!
        .channel('reading_sessions')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reading_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'client_id',
            value: userId,
          ),
          callback: (payload) {
            // Handle reading session updates
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reading_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'reader_id',
            value: userId,
          ),
          callback: (payload) {
            // Handle reading session updates
          },
        )
        .subscribe();
  }
}