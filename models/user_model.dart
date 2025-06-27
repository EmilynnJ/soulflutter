enum UserRole {
  client,
  reader,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final double accountBalance;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Reader-specific fields
  final ReaderProfile? readerProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.username,
    this.avatarUrl,
    this.bio,
    this.accountBalance = 0.0,
    this.isOnline = false,
    required this.createdAt,
    required this.updatedAt,
    this.readerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.client,
      ),
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      accountBalance: (json['account_balance'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['is_online'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      readerProfile: json['reader_profile'] != null 
          ? ReaderProfile.fromJson(json['reader_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.toString().split('.').last,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'account_balance': accountBalance,
      'is_online': isOnline,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (readerProfile != null) 'reader_profile': readerProfile!.toJson(),
    };
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    UserRole? role,
    String? username,
    String? avatarUrl,
    String? bio,
    double? accountBalance,
    bool? isOnline,
    DateTime? updatedAt,
    ReaderProfile? readerProfile,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      accountBalance: accountBalance ?? this.accountBalance,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readerProfile: readerProfile ?? this.readerProfile,
    );
  }

  bool get isReader => role == UserRole.reader;
  bool get isClient => role == UserRole.client;
  bool get isAdmin => role == UserRole.admin;
  String get displayName => username ?? fullName;
}

class ReaderProfile {
  final String userId;
  final String specializations;
  final double chatRate; // Per minute rate for chat
  final double phoneRate; // Per minute rate for phone
  final double videoRate; // Per minute rate for video
  final double rating;
  final int totalReadings;
  final int totalReviews;
  final bool isAvailable;
  final String? tagline;
  final List<String> tools; // Tarot, crystals, etc.
  final int yearsExperience;
  final double totalEarnings;
  final double pendingEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReaderProfile({
    required this.userId,
    required this.specializations,
    required this.chatRate,
    required this.phoneRate,
    required this.videoRate,
    this.rating = 0.0,
    this.totalReadings = 0,
    this.totalReviews = 0,
    this.isAvailable = false,
    this.tagline,
    this.tools = const [],
    this.yearsExperience = 0,
    this.totalEarnings = 0.0,
    this.pendingEarnings = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReaderProfile.fromJson(Map<String, dynamic> json) {
    return ReaderProfile(
      userId: json['user_id'] as String,
      specializations: json['specializations'] as String,
      chatRate: (json['chat_rate'] as num).toDouble(),
      phoneRate: (json['phone_rate'] as num).toDouble(),
      videoRate: (json['video_rate'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReadings: json['total_readings'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      tagline: json['tagline'] as String?,
      tools: (json['tools'] as List<dynamic>?)?.cast<String>() ?? [],
      yearsExperience: json['years_experience'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'specializations': specializations,
      'chat_rate': chatRate,
      'phone_rate': phoneRate,
      'video_rate': videoRate,
      'rating': rating,
      'total_readings': totalReadings,
      'total_reviews': totalReviews,
      'is_available': isAvailable,
      'tagline': tagline,
      'tools': tools,
      'years_experience': yearsExperience,
      'total_earnings': totalEarnings,
      'pending_earnings': pendingEarnings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReaderProfile copyWith({
    String? specializations,
    double? chatRate,
    double? phoneRate,
    double? videoRate,
    double? rating,
    int? totalReadings,
    int? totalReviews,
    bool? isAvailable,
    String? tagline,
    List<String>? tools,
    int? yearsExperience,
    double? totalEarnings,
    double? pendingEarnings,
    DateTime? updatedAt,
  }) {
    return ReaderProfile(
      userId: userId,
      specializations: specializations ?? this.specializations,
      chatRate: chatRate ?? this.chatRate,
      phoneRate: phoneRate ?? this.phoneRate,
      videoRate: videoRate ?? this.videoRate,
      rating: rating ?? this.rating,
      totalReadings: totalReadings ?? this.totalReadings,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      tagline: tagline ?? this.tagline,
      tools: tools ?? this.tools,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedRating => rating.toStringAsFixed(1);
  String get experienceText => '$yearsExperience ${yearsExperience == 1 ? 'year' : 'years'} experience';
}