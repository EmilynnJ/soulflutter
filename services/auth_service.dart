import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  static SupabaseClient? get _client => SupabaseConfig.client;

  // Get current user
  static User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (e) {
      return null;
    }
  }
  static bool get isLoggedIn => currentUser != null;

  // Sign up with role
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? username,
  }) async {
    if (_client == null) {
      throw Exception('Authentication service is not available. Please configure Supabase credentials to enable user registration.');
    }
    
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _client!.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role.name,
          'username': username,
        });

        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Sign in
  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_client == null) {
        // Demo mode - check for specific accounts
        if (email == 'emilynnj14@gmail.com' && password == 'JayJas1423!') {
          return UserModel(
            id: 'admin_demo',
            email: email,
            fullName: 'Emily Admin',
            role: UserRole.admin,
            username: 'emily_admin',
            bio: 'Platform administrator',
            accountBalance: 0.0,
            isOnline: true,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
          );
        } else if (email == 'emilynn992@gmail.com' && password == 'JayJas1423!') {
          return _getSampleReaders().firstWhere((r) => r.email == email);
        } else if (email == 'emily81292@gmail.com' && password == 'JayJas1423!') {
          return UserModel(
            id: 'client_demo',
            email: email,
            fullName: 'Emily Client',
            role: UserRole.client,
            username: 'emily_seeker',
            bio: 'Seeking spiritual guidance and clarity',
            accountBalance: 100.0,
            isOnline: true,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
          );
        }
        throw Exception('Demo mode: Invalid credentials. Use the provided demo accounts.');
      }
      
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Sign out
  static Future<void> signOut() async {
    if (_client == null) return;
    
    try {
      await _client!.auth.signOut();
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Get user profile with reader profile if applicable
  static Future<UserModel?> getUserProfile(String userId) async {
    if (_client == null) return null;
    
    try {
      final response = await _client!
          .from('users')
          .select('*, reader_profiles(*)')
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (currentUser == null) return null;
      return await getUserProfile(currentUser!.id);
    } catch (e) {
      // If backend is not available, return null (user not logged in)
      return null;
    }
  }

  // Update user profile
  static Future<UserModel?> updateProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (_client == null) return null;
      await _client!.from('users').update(updates).eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Update reader profile
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
      final updates = <String, dynamic>{};
      if (specializations != null) updates['specializations'] = specializations;
      if (chatRate != null) updates['chat_rate'] = chatRate;
      if (phoneRate != null) updates['phone_rate'] = phoneRate;
      if (videoRate != null) updates['video_rate'] = videoRate;
      if (isAvailable != null) updates['is_available'] = isAvailable;
      if (tagline != null) updates['tagline'] = tagline;
      if (tools != null) updates['tools'] = tools;
      if (yearsExperience != null) updates['years_experience'] = yearsExperience;
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (_client == null) return null;
      final response = await _client!
          .from('reader_profiles')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return ReaderProfile.fromJson(response);
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Update online status
  static Future<void> updateOnlineStatus(bool isOnline) async {
    if (currentUser == null) return;
    
    try {
      if (_client == null) return;
      await _client!.from('users').update({
        'is_online': isOnline,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Get all available readers
  static Future<List<UserModel>> getAvailableReaders() async {
    if (_client == null) {
      // Return sample readers for demo mode
      return _getSampleReaders();
    }
    
    try {
      final response = await _client!
          .from('users')
          .select('*, reader_profiles(*)')
          .eq('role', 'reader')
          .eq('reader_profiles.is_available', true);
      
      return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback to sample data if there's an error
      return _getSampleReaders();
    }
  }

  // Get top rated readers
  static Future<List<UserModel>> getTopRatedReaders({int limit = 10}) async {
    if (_client == null) {
      // Return sample readers for demo mode
      return _getSampleReaders().take(limit).toList();
    }
    
    try {
      final response = await _client!
          .from('users')
          .select('*, reader_profiles(*)')
          .eq('role', 'reader')
          .order('reader_profiles.rating', ascending: false)
          .limit(limit);
      
      return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback to sample data if there's an error
      return _getSampleReaders().take(limit).toList();
    }
  }

  // Search readers by specialization
  static Future<List<UserModel>> searchReaders(String query) async {
    try {
      if (_client == null) {
        return _getSampleReaders()
            .where((reader) => 
                reader.readerProfile?.specializations
                    .toLowerCase()
                    .contains(query.toLowerCase()) ?? false)
            .toList();
      }
      final response = await _client!
          .from('users')
          .select('*, reader_profiles(*)')
          .eq('role', 'reader')
          .ilike('reader_profiles.specializations', '%$query%')
          .order('reader_profiles.rating', ascending: false);

      return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return _getSampleReaders()
          .where((reader) => 
              reader.readerProfile?.specializations
                  .toLowerCase()
                  .contains(query.toLowerCase()) ?? false)
          .toList();
    }
  }

  // Add funds to account
  static Future<void> addFunds(double amount) async {
    if (currentUser == null) return;
    
    try {
      if (_client == null) return;
      await _client!.rpc('add_user_funds', params: {
        'user_id': currentUser!.id,
        'amount': amount,
      });
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Auth state changes stream
  static Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  // Error handling
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('SUPABASE_URL') || error.toString().contains('SUPABASE_ANON_KEY')) {
      return 'Backend service is not configured. Running in demo mode.';
    }
    return error.toString();
  }

  // Admin functions
  static Future<UserModel?> createReaderAccount({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String? bio,
    required String specializations,
    required double chatRate,
    required double phoneRate,
    required double videoRate,
    String? tagline,
    List<String>? tools,
    int yearsExperience = 0,
  }) async {
    try {
      // Create user account first
      final user = await signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: UserRole.reader,
        username: username,
      );

      if (user != null) {
        // Create reader profile
        if (_client == null) return null;
        await _client!.from('reader_profiles').insert({
          'user_id': user.id,
          'specializations': specializations,
          'chat_rate': chatRate,
          'phone_rate': phoneRate,
          'video_rate': videoRate,
          'tagline': tagline,
          'tools': tools ?? [],
          'years_experience': yearsExperience,
        });

        // Update user bio if provided
        if (bio != null) {
          await updateProfile(userId: user.id, bio: bio);
        }

        return await getUserProfile(user.id);
      }
      return null;
    } catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  // Demo mode sample readers
  static List<UserModel> _getSampleReaders() {
    return [
      // Custom reader account for Emily
      UserModel(
        id: 'emily_reader',
        email: 'emilynn992@gmail.com',
        fullName: 'Emily Reader',
        role: UserRole.reader,
        username: 'emily_mystic',
        bio: 'Professional spiritual advisor with years of experience in tarot, astrology, and energy healing.',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'emily_reader',
          specializations: 'Tarot Reading, Astrology, Energy Healing',
          chatRate: 3.99,
          phoneRate: 6.99,
          videoRate: 8.99,
          rating: 4.7,
          totalReadings: 45,
          totalReviews: 42,
          isAvailable: true,
          tagline: 'Bringing clarity to life\'s mysteries ✨',
          tools: ['Tarot Cards', 'Astrology Charts', 'Crystal Healing'],
          yearsExperience: 5,
          totalEarnings: 890.50,
          pendingEarnings: 150.00,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: 'sample1',
        email: 'luna@example.com',
        fullName: 'Luna Mystic',
        role: UserRole.reader,
        username: 'mystic_luna',
        bio: 'Experienced tarot reader and spiritual guide with 10+ years of experience.',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'sample1',
          specializations: 'Love & Relationships, Career Guidance, Life Purpose',
          chatRate: 2.99,
          phoneRate: 4.99,
          videoRate: 6.99,
          rating: 4.8,
          totalReadings: 156,
          totalReviews: 142,
          isAvailable: true,
          tagline: 'Let the cards reveal your destiny ✨',
          tools: ['Tarot Cards', 'Oracle Cards', 'Numerology'],
          yearsExperience: 12,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: 'sample2',
        email: 'cosmic@example.com',
        fullName: 'Cosmic Sage',
        role: UserRole.reader,
        username: 'cosmic_sage',
        bio: 'Psychic medium connecting with spirit guides and passed loved ones.',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'sample2',
          specializations: 'Mediumship, Spirit Communication, Energy Healing',
          chatRate: 3.49,
          phoneRate: 5.49,
          videoRate: 7.99,
          rating: 4.9,
          totalReadings: 89,
          totalReviews: 81,
          isAvailable: true,
          tagline: 'Bridging the worlds between spirit and soul 🔮',
          tools: ['Crystals', 'Chakra Healing', 'Spirit Communication'],
          yearsExperience: 8,
          createdAt: DateTime.now().subtract(const Duration(days: 300)),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: 'sample3',
        email: 'crystal@example.com',
        fullName: 'Crystal Oracle',
        role: UserRole.reader,
        username: 'crystal_oracle',
        bio: 'Oracle card reader and astrologer helping souls find their path.',
        isOnline: false,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'sample3',
          specializations: 'Astrology, Oracle Reading, Past Life',
          chatRate: 2.49,
          phoneRate: 3.99,
          videoRate: 5.99,
          rating: 4.6,
          totalReadings: 203,
          totalReviews: 187,
          isAvailable: false,
          tagline: 'Ancient wisdom for modern souls 🌙',
          tools: ['Oracle Cards', 'Astrology', 'Crystal Ball'],
          yearsExperience: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: 'sample4',
        email: 'serene@example.com',
        fullName: 'Serene Spirit',
        role: UserRole.reader,
        username: 'serene_spirit',
        bio: 'Energy healer specializing in chakra balancing and spiritual cleansing.',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'sample4',
          specializations: 'Energy Healing, Chakra Balancing, Spiritual Cleansing',
          chatRate: 3.99,
          phoneRate: 6.49,
          videoRate: 8.99,
          rating: 4.7,
          totalReadings: 67,
          totalReviews: 62,
          isAvailable: true,
          tagline: 'Healing energy flows through divine connection 🌟',
          tools: ['Crystals', 'Reiki', 'Chakra Stones'],
          yearsExperience: 6,
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
          updatedAt: DateTime.now(),
        ),
      ),
      UserModel(
        id: 'sample5',
        email: 'divine@example.com',
        fullName: 'Divine Mystic',
        role: UserRole.reader,
        username: 'divine_mystic',
        bio: 'Twin flame specialist and spiritual counselor for soul connections.',
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now(),
        readerProfile: ReaderProfile(
          userId: 'sample5',
          specializations: 'Twin Flames, Soul Connections, Spiritual Counseling',
          chatRate: 4.49,
          phoneRate: 7.99,
          videoRate: 9.99,
          rating: 4.9,
          totalReadings: 134,
          totalReviews: 128,
          isAvailable: true,
          tagline: 'Guiding souls to their divine connection 💕',
          tools: ['Tarot', 'Angel Cards', 'Meditation'],
          yearsExperience: 10,
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
      ),
    ];
  }
}