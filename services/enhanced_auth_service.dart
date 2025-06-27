import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/user_model.dart';
import '../models/reading_session.dart';
import '../models/transaction.dart';

class EnhancedAuthService {
  static SupabaseClient? get _client => SupabaseConfig.client;
  static StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  
  // Enhanced user state management
  static Stream<UserModel?> get userStream => _userController.stream;
  static UserModel? _currentUserCache;
  
  // Get current user with caching
  static User? get currentUser => _client?.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static UserModel? get currentUserProfile => _currentUserCache;

  // Initialize auth service
  static Future<void> initialize() async {
    try {
      // Only initialize if Supabase client is available
      if (_client != null) {
        // Listen to auth state changes
        _client!.auth.onAuthStateChange.listen((data) async {
          if (data.session?.user != null) {
            await _loadUserProfile(data.session!.user.id);
          } else {
            _currentUserCache = null;
            _userController.add(null);
          }
        });
        
        // Load current user if already authenticated
        if (isLoggedIn) {
          await _loadUserProfile(currentUser!.id);
        }
      } else {
        // Running in demo mode - just initialize with null user
        print('EnhancedAuthService: Running in demo mode');
        _currentUserCache = null;
        _userController.add(null);
      }
    } catch (e) {
      print('Error initializing EnhancedAuthService: $e');
      _currentUserCache = null;
      _userController.add(null);
    }
  }

  // Load user profile with caching
  static Future<void> _loadUserProfile(String userId) async {
    try {
      final userProfile = await getUserProfile(userId);
      _currentUserCache = userProfile;
      _userController.add(userProfile);
    } catch (e) {
      print('Error loading user profile: $e');
      _currentUserCache = null;
      _userController.add(null);
    }
  }

  // Enhanced sign up with better validation
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? username,
    String? bio,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      
      if (!_isValidPassword(password)) {
        throw Exception('Password must be at least 8 characters with uppercase, lowercase, and number');
      }

      final response = await _client?.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
          'username': username,
          'bio': bio,
        },
      );

      if (response != null && response.user != null) {
        // Create user profile in users table
        await _client?.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role.name,
          'username': username,
          'bio': bio,
          'account_balance': 0.00,
          'is_online': false,
        });

        // Create reader profile if role is reader
        if (role == UserRole.reader) {
          await _client?.from('reader_profiles').insert({
            'user_id': response.user!.id,
            'specializations': '',
            'chat_rate': 2.99,
            'phone_rate': 4.99,
            'video_rate': 6.99,
            'rating': 0.0,
            'total_readings': 0,
            'total_reviews': 0,
            'is_available': false,
            'tagline': '',
            'tools': [],
            'years_experience': 0,
            'total_earnings': 0.0,
            'pending_earnings': 0.0,
          });
        }

        await _loadUserProfile(response.user!.id);
        return _currentUserCache;
      }
      return null;
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Enhanced sign in with better error handling
  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client?.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response != null && response.user != null) {
        await _loadUserProfile(response.user!.id);
        await updateOnlineStatus(true);
        return _currentUserCache;
      }
      return null;
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Enhanced sign out
  static Future<void> signOut() async {
    try {
      if (isLoggedIn) {
        await updateOnlineStatus(false);
      }
      await _client?.auth.signOut();
      _currentUserCache = null;
      _userController.add(null);
    } catch (e) {
      throw Exception('Failed to sign out: ${getErrorMessage(e)}');
    }
  }

  // Get user profile with error handling
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      // Return null if client is not available (demo mode)
      if (_client == null) {
        print('getUserProfile: Running in demo mode');
        return null;
      }
      
      final response = await _client!
          .from('users')
          .select('''
            *,
            reader_profiles (*)
          ''')
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  // Enhanced profile update
  static Future<UserModel?> updateProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await _client?.from('users').update(updateData).eq('id', userId);
      
      await _loadUserProfile(userId);
      return _currentUserCache;
    } catch (e) {
      throw Exception('Failed to update profile: ${getErrorMessage(e)}');
    }
  }

  // Enhanced reader profile update
  static Future<ReaderProfile?> updateReaderProfile({
    required String userId,
    String? specializations,
    double? chatRate,
    double? phoneRate,
    double? videoRate,
    bool? isAvailable,
    String? tagline,
    List<String>? tools,
    int? yearsExperience,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (specializations != null) updateData['specializations'] = specializations;
      if (chatRate != null) updateData['chat_rate'] = chatRate;
      if (phoneRate != null) updateData['phone_rate'] = phoneRate;
      if (videoRate != null) updateData['video_rate'] = videoRate;
      if (isAvailable != null) updateData['is_available'] = isAvailable;
      if (tagline != null) updateData['tagline'] = tagline;
      if (tools != null) updateData['tools'] = tools;
      if (yearsExperience != null) updateData['years_experience'] = yearsExperience;

      await _client?.from('reader_profiles').update(updateData).eq('user_id', userId);
      
      await _loadUserProfile(userId);
      return _currentUserCache?.readerProfile;
    } catch (e) {
      throw Exception('Failed to update reader profile: ${getErrorMessage(e)}');
    }
  }

  // Update online status
  static Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      if (currentUser != null) {
        await _client?.from('users').update({
          'is_online': isOnline,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.id);
        
        if (_currentUserCache != null) {
          _currentUserCache = _currentUserCache!.copyWith(isOnline: isOnline);
          _userController.add(_currentUserCache);
        }
      }
    } catch (e) {
      print('Failed to update online status: $e');
    }
  }

  // Password reset
  static Future<void> resetPassword(String email) async {
    try {
      await _client?.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset: ${getErrorMessage(e)}');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      if (!_isValidPassword(newPassword)) {
        throw Exception('Password must be at least 8 characters with uppercase, lowercase, and number');
      }
      
      await _client?.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Failed to update password: ${getErrorMessage(e)}');
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Update online status first
        await updateOnlineStatus(false);
        
        // Delete user data (cascade will handle related records)
        await _client?.from('users').delete().eq('id', currentUser!.id);
        
        // Sign out
        await signOut();
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${getErrorMessage(e)}');
    }
  }

  // Get available readers with enhanced filtering
  static Future<List<UserModel>> getAvailableReaders({
    String? specialization,
    double? maxRate,
    double? minRating,
    int limit = 20,
  }) async {
    try {
      var query = _client
          ?.from('users')
          .select('''
            *,
            reader_profiles!inner (*)
          ''')
          .eq('role', 'reader')
          .eq('reader_profiles.is_available', true)
          .order('reader_profiles.rating', ascending: false);

      // Apply filters using order and limit for now
      // TODO: Implement proper filtering when available

      final response = await query?.limit(limit);
      
      if (response != null) {
        return response.map((data) => UserModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading available readers: $e');
      return [];
    }
  }

  // Add funds to account
  static Future<void> addFunds(double amount) async {
    try {
      if (currentUser != null && amount > 0) {
        await _client?.from('users').update({
          'account_balance': (_currentUserCache?.accountBalance ?? 0) + amount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.id);
        
        // Record transaction
        await _client?.from('transactions').insert({
          'user_id': currentUser!.id,
          'type': 'top_up',
          'amount': amount,
          'status': 'completed',
          'description': 'Account balance top-up',
        });
        
        await _loadUserProfile(currentUser!.id);
      }
    } catch (e) {
      throw Exception('Failed to add funds: ${getErrorMessage(e)}');
    }
  }

  // Validation helpers
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool _isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  // Enhanced error handling
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    } else if (error.toString().contains('Email not confirmed')) {
      return 'Please check your email and confirm your account before signing in.';
    } else if (error.toString().contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (error.toString().contains('Password should be at least 6 characters')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.toString().contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    } else if (error.toString().contains('Network error')) {
      return 'Network connection failed. Please check your internet connection.';
    }
    
    String errorStr = error.toString();
    if (errorStr.contains('Exception: ')) {
      errorStr = errorStr.replaceFirst('Exception: ', '');
    }
    
    return errorStr;
  }

  // Get user sessions
  static Future<List<ReadingSession>> getUserSessions(String userId) async {
    try {
      // Return empty list if client is not available (demo mode)
      if (_client == null) {
        print('getUserSessions: Running in demo mode');
        return _generateDemoSessions();
      }
      
      final response = await _client!
          .from('reading_sessions')
          .select('''
            *,
            readers:reader_id (full_name)
          ''')
          .eq('client_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((data) {
        // Add reader name to session data
        if (data['readers'] != null) {
          data['reader_name'] = data['readers']['full_name'];
        }
        return ReadingSession.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error loading user sessions: $e');
      return _generateDemoSessions();
    }
  }

  // Get user transactions
  static Future<List<Transaction>> getUserTransactions(String userId) async {
    try {
      // Return empty list if client is not available (demo mode)
      if (_client == null) {
        print('getUserTransactions: Running in demo mode');
        return _generateDemoTransactions();
      }
      
      final response = await _client!
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((data) => Transaction.fromJson(data)).toList();
    } catch (e) {
      print('Error loading user transactions: $e');
      return _generateDemoTransactions();
    }
  }

  // Get favorite readers
  static Future<List<UserModel>> getFavoriteReaders(String userId) async {
    try {
      // Return empty list if client is not available (demo mode)
      if (_client == null) {
        print('getFavoriteReaders: Running in demo mode');
        return _generateDemoReaders();
      }
      
      final response = await _client!
          .from('favorite_readers')
          .select('''
            readers:reader_id (
              *,
              reader_profiles (*)
            )
          ''')
          .eq('user_id', userId);
      
      return response.map((data) {
        final readerData = data['readers'];
        return UserModel.fromJson(readerData);
      }).toList();
    } catch (e) {
      print('Error loading favorite readers: $e');
      return _generateDemoReaders();
    }
  }

  // Add favorite reader
  static Future<void> addFavoriteReader(String userId, String readerId) async {
    try {
      await _client?.from('favorite_readers').insert({
        'user_id': userId,
        'reader_id': readerId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add favorite reader: ${getErrorMessage(e)}');
    }
  }

  // Remove favorite reader
  static Future<void> removeFavoriteReader(String userId, String readerId) async {
    try {
      await _client
          ?.from('favorite_readers')
          .delete()
          .eq('user_id', userId)
          .eq('reader_id', readerId);
    } catch (e) {
      throw Exception('Failed to remove favorite reader: ${getErrorMessage(e)}');
    }
  }

  // Check if reader is favorited
  static Future<bool> isReaderFavorited(String userId, String readerId) async {
    try {
      final response = await _client
          ?.from('favorite_readers')
          .select('id')
          .eq('user_id', userId)
          .eq('reader_id', readerId)
          .limit(1);
      
      return response?.isNotEmpty ?? false;
    } catch (e) {
      print('Error checking if reader is favorited: $e');
      return false;
    }
  }

  // Demo data generation methods for when Supabase is not available
  static List<ReadingSession> _generateDemoSessions() {
    return [
      ReadingSession(
        id: 'demo_1',
        clientId: 'demo_user',
        readerId: 'demo_reader_1',
        type: ReadingType.video,
        status: ReadingStatus.completed,
        perMinuteRate: 6.99,
        totalCost: 20.97,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        readerName: 'Mystic Luna',
      ),
      ReadingSession(
        id: 'demo_2',
        clientId: 'demo_user',
        readerId: 'demo_reader_2',
        type: ReadingType.chat,
        status: ReadingStatus.completed,
        perMinuteRate: 2.99,
        totalCost: 14.95,
        startTime: DateTime.now().subtract(const Duration(days: 3)),
        endTime: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        readerName: 'Crystal Sage',
      ),
    ];
  }

  static List<Transaction> _generateDemoTransactions() {
    return [
      Transaction(
        id: 'demo_trans_1',
        userId: 'demo_user',
        amount: 20.97,
        type: 'reading_payment',
        status: 'completed',
        description: 'Video reading session with Mystic Luna',
        sessionId: 'demo_1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'demo_trans_2',
        userId: 'demo_user',
        amount: 14.95,
        type: 'reading_payment',
        status: 'completed',
        description: 'Chat reading session with Crystal Sage',
        sessionId: 'demo_2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<UserModel> _generateDemoReaders() {
    return [
      UserModel(
        id: 'demo_reader_1',
        email: 'luna@soulseer.com',
        fullName: 'Mystic Luna',
        role: UserRole.reader,
        username: 'mystic_luna',
        bio: 'Gifted tarot reader with 10+ years of experience',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: 'demo_reader_2',
        email: 'sage@soulseer.com',
        fullName: 'Crystal Sage',
        role: UserRole.reader,
        username: 'crystal_sage',
        bio: 'Psychic medium specializing in love and relationships',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Dispose resources
  static void dispose() {
    _userController.close();
  }
}