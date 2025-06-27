import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user; // Optional user data
  final bool? isLikedByCurrentUser; // Whether current user liked this post

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isLikedByCurrentUser,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      if (isLikedByCurrentUser != null) 'is_liked_by_current_user': isLikedByCurrentUser,
    };
  }

  PostModel copyWith({
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    DateTime? updatedAt,
    UserModel? user,
    bool? isLikedByCurrentUser,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}