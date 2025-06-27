import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';


class ReaderCard extends StatefulWidget {
  final UserModel reader;
  final bool isOnline;
  final bool showFullCard;
  final VoidCallback? onTap;

  const ReaderCard({
    super.key,
    required this.reader,
    this.isOnline = false,
    this.showFullCard = false,
    this.onTap,
  });

  @override
  State<ReaderCard> createState() => _ReaderCardState();
}

class _ReaderCardState extends State<ReaderCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _animationController.forward();
  }

  void _onTapUp() {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.reader.readerProfile == null) {
      return const SizedBox.shrink();
    }

    final profile = widget.reader.readerProfile!;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
            onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
            onTapCancel: widget.onTap != null ? _onTapCancel : null,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isOnline
                    ? theme.colorScheme.secondary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isOnline 
                      ? theme.colorScheme.secondary 
                      : theme.colorScheme.primary).withOpacity(0.1 + 0.1 * _glowAnimation.value),
                    blurRadius: 8 + 4 * _glowAnimation.value,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.showFullCard 
                ? _buildFullCard(theme, profile)
                : _buildCompactCard(theme, profile),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactCard(ThemeData theme, ReaderProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and status
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: widget.reader.avatarUrl != null
                        ? NetworkImage(widget.reader.avatarUrl!)
                        : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: widget.reader.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                            size: 24,
                          )
                        : null,
                  ),
                  if (widget.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reader.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profile.tagline != null)
                      Text(
                        profile.tagline!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: theme.colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.formattedRating,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${profile.totalReviews} reviews',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Specializations
          Text(
            profile.specializations,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Pricing
          Row(
            children: [
              _buildPriceCard(theme, 'Chat', Icons.chat, '\$${profile.chatRate.toStringAsFixed(2)}/min'),
              const SizedBox(width: 8),
              _buildPriceCard(theme, 'Video', Icons.videocam, '\$${profile.videoRate.toStringAsFixed(2)}/min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard(ThemeData theme, ReaderProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderContent(theme, profile),
          
          const SizedBox(height: 16),
          
          // Bio
          if (widget.reader.bio != null) ...[
            Text(
              widget.reader.bio!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          
          // Tools and experience
          if (profile.tools.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: profile.tools.take(4).map((tool) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tool,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Pricing grid
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(theme, 'Chat', Icons.chat, '\$${profile.chatRate.toStringAsFixed(2)}/min'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceCard(theme, 'Phone', Icons.phone, '\$${profile.phoneRate.toStringAsFixed(2)}/min'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceCard(theme, 'Video', Icons.videocam, '\$${profile.videoRate.toStringAsFixed(2)}/min'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(ThemeData theme, ReaderProfile profile) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: widget.reader.avatarUrl != null
                  ? NetworkImage(widget.reader.avatarUrl!)
                  : null,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: widget.reader.avatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: 32,
                    )
                  : null,
            ),
            if (widget.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.reader.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (profile.tagline != null) ...[
                const SizedBox(height: 4),
                Text(
                  profile.tagline!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: theme.colorScheme.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.formattedRating,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${profile.totalReadings} readings',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    profile.experienceText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(ThemeData theme, String title, IconData icon, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.secondary,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
          Text(
            price,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}