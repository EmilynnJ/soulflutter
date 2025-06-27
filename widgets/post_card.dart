import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';


class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLikeChanged;
  final VoidCallback? onDeleted;

  const PostCard({
    super.key,
    required this.post,
    this.onLikeChanged,
    this.onDeleted,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late PostModel _post;
  bool _isLiking = false;
  
  late AnimationController _likeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _likeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    
    setState(() {
      _isLiking = true;
    });
    
    try {
      // Optimistic UI update
      final wasLiked = _post.isLikedByCurrentUser == true;
      setState(() {
        _post = _post.copyWith(
          isLikedByCurrentUser: !wasLiked,
          likesCount: wasLiked ? _post.likesCount - 1 : _post.likesCount + 1,
        );
      });
      
      // Animate
      if (!wasLiked) {
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
      }
      
      // Make API call
      final newLikeStatus = await PostService.likePost(_post.id);
      
      // Update with actual result
      setState(() {
        _post = _post.copyWith(isLikedByCurrentUser: newLikeStatus);
      });
      
      widget.onLikeChanged?.call();
    } catch (e) {
      // Revert optimistic update on error
      final wasLiked = _post.isLikedByCurrentUser == true;
      setState(() {
        _post = _post.copyWith(
          isLikedByCurrentUser: !wasLiked,
          likesCount: wasLiked ? _post.likesCount + 1 : _post.likesCount - 1,
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update like status'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _post.user;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light 
              ? Colors.white 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: user?.avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Unknown User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '@${user?.username ?? 'unknown'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Timestamp
                  Text(
                    timeago.format(_post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Post Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _post.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            
            // Post Image
            if (_post.imageUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _post.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.error,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Like Button
                  AnimatedBuilder(
                    animation: _likeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _likeAnimation.value,
                        child: InkWell(
                          onTap: _toggleLike,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: (_post.isLikedByCurrentUser == true)
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (_post.isLikedByCurrentUser == true)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color: (_post.isLikedByCurrentUser == true)
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                if (_post.likesCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    _post.likesCount.toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: (_post.isLikedByCurrentUser == true)
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Comment Button
                  InkWell(
                    onTap: () {
                      // TODO: Implement comments
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comments feature coming soon!'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          if (_post.commentsCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              _post.commentsCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Share Button
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}