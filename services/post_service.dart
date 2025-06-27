import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostService {
  static SupabaseClient? get _client => SupabaseConfig.client;

  // Create a new post
  static Future<PostModel?> createPost({
    required String content,
    String? imageUrl,
  }) async {
    if (_client == null) {
      throw Exception('Post creation is not available in demo mode. Please configure Supabase to enable posting.');
    }
    
    try {
      final currentUser = SupabaseConfig.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _client!
          .from('posts')
          .insert({
            'user_id': currentUser.id,
            'content': content,
            'image_url': imageUrl,
          })
          .select('''
            *,
            user:users(*)
          ''')
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get posts feed with user information
  static Future<List<PostModel>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    if (_client == null) {
      // Return sample posts for demo mode
      return _getSamplePosts();
    }
    
    try {
      final response = await _client!
          .from('posts')
          .select('''
            *,
            users!posts_user_id_fkey (
              id,
              full_name,
              username,
              avatar_url,
              role,
              reader_profiles (
                tagline,
                specializations
              )
            )
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      List<PostModel> posts = [];
      
      for (var postData in response) {
        try {
          // Handle potential null user data
          Map<String, dynamic> userData = postData['users'] ?? {};
          
          UserModel? user;
          if (userData.isNotEmpty) {
            user = UserModel.fromJson(userData);
          }
          
          // Check if current user liked this post
          bool? isLikedByCurrentUser;
          final currentUser = SupabaseConfig.currentUser;
          if (currentUser != null) {
            final likeCheck = await _client!
                .from('post_likes')
                .select('id')
                .eq('post_id', postData['id'])
                .eq('user_id', currentUser.id)
                .maybeSingle();
            isLikedByCurrentUser = likeCheck != null;
          }
          
          PostModel post = PostModel.fromJson(postData);
          post = post.copyWith(
            user: user,
            isLikedByCurrentUser: isLikedByCurrentUser,
          );
          
          posts.add(post);
        } catch (e) {
          print('Error parsing post: $e');
          // Continue with other posts even if one fails
        }
      }
      
      return posts;
    } catch (e) {
      // Fallback to sample posts if there's an error
      return _getSamplePosts();
    }
  }

  // Get posts by specific user
  static Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (_client == null) return [];
      final response = await _client!
          .from('posts')
          .select('''
            *,
            user:users(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<PostModel>((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Like a post
  static Future<bool> likePost(String postId) async {
    if (_client == null) {
      throw Exception('Like functionality is not available in demo mode. Please configure Supabase to enable interactions.');
    }
    
    try {
      final currentUser = SupabaseConfig.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Check if already liked
      final existingLike = await _client!
          .from('post_likes')
          .select()
          .eq('user_id', currentUser.id)
          .eq('post_id', postId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the post
        await _client!
            .from('post_likes')
            .delete()
            .eq('user_id', currentUser.id)
            .eq('post_id', postId);

        // Decrement likes count
        await _client!.rpc('decrement_post_likes', params: {'post_id': postId});
        
        return false; // Post was unliked
      } else {
        // Like the post
        await _client!
            .from('post_likes')
            .insert({
              'user_id': currentUser.id,
              'post_id': postId,
            });

        // Increment likes count
        await _client!.rpc('increment_post_likes', params: {'post_id': postId});
        
        return true; // Post was liked
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a post
  static Future<void> deletePost(String postId) async {
    if (_client == null) {
      throw Exception('Delete functionality is not available in demo mode. Please configure Supabase to enable interactions.');
    }
    
    try {
      final currentUser = SupabaseConfig.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _client!
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', currentUser.id); // Ensure user can only delete their own posts
    } catch (e) {
      rethrow;
    }
  }

  // Subscribe to real-time posts updates
  static RealtimeChannel? subscribeToFeedUpdates({
    required Function(PostModel) onPostInserted,
    required Function(PostModel) onPostUpdated,
    required Function(String) onPostDeleted,
  }) {
    if (_client == null) return null;
    
    return _client!
        .channel('posts_feed')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            try {
              // Fetch the complete post with user data
              final response = await _client!
                  .from('posts')
                  .select('''
                    *,
                    user:users(*)
                  ''')
                  .eq('id', payload.newRecord['id'])
                  .single();

              onPostInserted(PostModel.fromJson(response));
            } catch (e) {
              // Handle error silently or log
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            try {
              final response = await _client!
                  .from('posts')
                  .select('''
                    *,
                    user:users(*)
                  ''')
                  .eq('id', payload.newRecord['id'])
                  .single();

              onPostUpdated(PostModel.fromJson(response));
            } catch (e) {
              // Handle error silently or log
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            onPostDeleted(payload.oldRecord['id'] as String);
          },
        )
        .subscribe();
  }

  // Demo mode sample posts
  static List<PostModel> _getSamplePosts() {
    return [
      PostModel(
        id: 'sample_post_1',
        userId: 'sample1',
        content: 'Welcome to our spiritual community! I\'m Luna and I\'ve been reading tarot for over 12 years. Tonight I\'m feeling the energy of new beginnings - perfect for those seeking clarity on their path. ✨🔮',
        likesCount: 15,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        user: UserModel(
          id: 'sample1',
          email: 'luna@example.com',
          fullName: 'Luna Mystic',
          role: UserRole.reader,
          username: 'mystic_luna',
          bio: 'Experienced tarot reader and spiritual guide',
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
          readerProfile: ReaderProfile(
            userId: 'sample1',
            specializations: 'Love & Relationships, Career Guidance',
            chatRate: 2.99,
            phoneRate: 4.99,
            videoRate: 6.99,
            tagline: 'Let the cards reveal your destiny ✨',
            createdAt: DateTime.now().subtract(const Duration(days: 365)),
            updatedAt: DateTime.now(),
          ),
        ),
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'sample_post_2',
        userId: 'sample2',
        content: 'Just finished an amazing session with a client who was looking for guidance about their twin flame connection. The spirits were so clear today! Remember, the universe always has a plan. 💫',
        likesCount: 8,
        commentsCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        user: UserModel(
          id: 'sample2',
          email: 'cosmic@example.com',
          fullName: 'Cosmic Sage',
          role: UserRole.reader,
          username: 'cosmic_sage',
          bio: 'Psychic medium and spiritual guide',
          createdAt: DateTime.now().subtract(const Duration(days: 300)),
          updatedAt: DateTime.now(),
          readerProfile: ReaderProfile(
            userId: 'sample2',
            specializations: 'Mediumship, Spirit Communication',
            chatRate: 3.49,
            phoneRate: 5.49,
            videoRate: 7.99,
            tagline: 'Bridging worlds between spirit and soul 🔮',
            createdAt: DateTime.now().subtract(const Duration(days: 300)),
            updatedAt: DateTime.now(),
          ),
        ),
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'sample_post_3',
        userId: 'sample5',
        content: 'Mercury retrograde is ending soon! This is a wonderful time to reflect on the lessons learned and prepare for forward movement. What insights have you gained during this introspective period? 🌙',
        likesCount: 12,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        user: UserModel(
          id: 'sample5',
          email: 'divine@example.com',
          fullName: 'Divine Mystic',
          role: UserRole.reader,
          username: 'divine_mystic',
          bio: 'Twin flame specialist and spiritual counselor',
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
          readerProfile: ReaderProfile(
            userId: 'sample5',
            specializations: 'Twin Flames, Soul Connections',
            chatRate: 4.49,
            phoneRate: 7.99,
            videoRate: 9.99,
            tagline: 'Guiding souls to their divine connection 💕',
            createdAt: DateTime.now().subtract(const Duration(days: 100)),
            updatedAt: DateTime.now(),
          ),
        ),
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'sample_post_4',
        userId: 'sample3',
        content: 'Full moon energy is building! Perfect time for manifestation and releasing what no longer serves you. I\'ll be doing a special oracle reading tonight for anyone who needs guidance. 🌕✨',
        likesCount: 22,
        commentsCount: 7,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        user: UserModel(
          id: 'sample3',
          email: 'crystal@example.com',
          fullName: 'Crystal Oracle',
          role: UserRole.reader,
          username: 'crystal_oracle',
          bio: 'Oracle card reader and astrologer',
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now(),
          readerProfile: ReaderProfile(
            userId: 'sample3',
            specializations: 'Astrology, Oracle Reading, Past Life',
            chatRate: 2.49,
            phoneRate: 3.99,
            videoRate: 5.99,
            tagline: 'Ancient wisdom for modern souls 🌙',
            createdAt: DateTime.now().subtract(const Duration(days: 200)),
            updatedAt: DateTime.now(),
          ),
        ),
        isLikedByCurrentUser: false,
      ),
    ];
  }
}