enum ReadingType {
  chat,
  phone,
  video,
}

enum ReadingStatus {
  pending,
  active,
  completed,
  cancelled,
  disputed,
}

class ReadingSession {
  final String id;
  final String clientId;
  final String readerId;
  final ReadingType type;
  final ReadingStatus status;
  final double perMinuteRate;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final double totalCost;
  final double readerEarnings; // 70% of totalCost
  final double platformFee; // 30% of totalCost
  final String? notes;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Real-time session data
  final bool isConnected;
  final String? connectionId;
  final Map<String, dynamic>? metadata;

  ReadingSession({
    required this.id,
    required this.clientId,
    required this.readerId,
    required this.type,
    required this.status,
    required this.perMinuteRate,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.totalCost = 0.0,
    this.readerEarnings = 0.0,
    this.platformFee = 0.0,
    this.notes,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.isConnected = false,
    this.connectionId,
    this.metadata,
  });

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      readerId: json['reader_id'] as String,
      type: ReadingType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ReadingType.chat,
      ),
      status: ReadingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReadingStatus.pending,
      ),
      perMinuteRate: (json['per_minute_rate'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      readerEarnings: (json['reader_earnings'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isConnected: json['is_connected'] as bool? ?? false,
      connectionId: json['connection_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'reader_id': readerId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'per_minute_rate': perMinuteRate,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'total_cost': totalCost,
      'reader_earnings': readerEarnings,
      'platform_fee': platformFee,
      'notes': notes,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_connected': isConnected,
      'connection_id': connectionId,
      'metadata': metadata,
    };
  }

  ReadingSession copyWith({
    ReadingType? type,
    ReadingStatus? status,
    double? perMinuteRate,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? totalCost,
    double? readerEarnings,
    double? platformFee,
    String? notes,
    double? rating,
    String? review,
    DateTime? updatedAt,
    bool? isConnected,
    String? connectionId,
    Map<String, dynamic>? metadata,
  }) {
    return ReadingSession(
      id: id,
      clientId: clientId,
      readerId: readerId,
      type: type ?? this.type,
      status: status ?? this.status,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalCost: totalCost ?? this.totalCost,
      readerEarnings: readerEarnings ?? this.readerEarnings,
      platformFee: platformFee ?? this.platformFee,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isConnected: isConnected ?? this.isConnected,
      connectionId: connectionId ?? this.connectionId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isActive => status == ReadingStatus.active;
  bool get isCompleted => status == ReadingStatus.completed;
  bool get canBeRated => isCompleted && rating == null;
  
  Duration get sessionDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }
  
  String get typeDisplayName {
    switch (type) {
      case ReadingType.chat:
        return 'Chat Reading';
      case ReadingType.phone:
        return 'Phone Reading';
      case ReadingType.video:
        return 'Video Reading';
    }
  }
  
  String get statusDisplayName {
    switch (status) {
      case ReadingStatus.pending:
        return 'Pending';
      case ReadingStatus.active:
        return 'Active';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.cancelled:
        return 'Cancelled';
      case ReadingStatus.disputed:
        return 'Disputed';
    }
  }

  // Calculate earnings based on 70/30 split
  static double calculateReaderEarnings(double totalCost) {
    return totalCost * 0.7;
  }
  
  static double calculatePlatformFee(double totalCost) {
    return totalCost * 0.3;
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? mediaUrl;
  final String? mediaType;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.mediaUrl,
    this.mediaType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'sender_id': senderId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'media_url': mediaUrl,
      'media_type': mediaType,
    };
  }

  ChatMessage copyWith({
    String? message,
    bool? isRead,
    String? mediaUrl,
    String? mediaType,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      senderId: senderId,
      message: message ?? this.message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
}