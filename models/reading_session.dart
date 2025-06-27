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
  final double? totalCost;
  final int? clientRating;
  final String? clientReview;
  final String? readerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for UI
  final String? readerName;
  final String? clientName;

  ReadingSession({
    required this.id,
    required this.clientId,
    required this.readerId,
    required this.type,
    required this.status,
    required this.perMinuteRate,
    required this.startTime,
    this.endTime,
    this.totalCost,
    this.clientRating,
    this.clientReview,
    this.readerNotes,
    required this.createdAt,
    required this.updatedAt,
    this.readerName,
    this.clientName,
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
      totalCost: json['total_cost'] != null 
          ? (json['total_cost'] as num).toDouble() 
          : null,
      clientRating: json['client_rating'] as int?,
      clientReview: json['client_review'] as String?,
      readerNotes: json['reader_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      readerName: json['reader_name'] as String?,
      clientName: json['client_name'] as String?,
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
      'total_cost': totalCost,
      'client_rating': clientRating,
      'client_review': clientReview,
      'reader_notes': readerNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReadingSession copyWith({
    String? id,
    String? clientId,
    String? readerId,
    ReadingType? type,
    ReadingStatus? status,
    double? perMinuteRate,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    int? clientRating,
    String? clientReview,
    String? readerNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? readerName,
    String? clientName,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      readerId: readerId ?? this.readerId,
      type: type ?? this.type,
      status: status ?? this.status,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCost: totalCost ?? this.totalCost,
      clientRating: clientRating ?? this.clientRating,
      clientReview: clientReview ?? this.clientReview,
      readerNotes: readerNotes ?? this.readerNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readerName: readerName ?? this.readerName,
      clientName: clientName ?? this.clientName,
    );
  }

  // Helper getters
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  int get durationInMinutes {
    return duration?.inMinutes ?? 0;
  }

  bool get isActive => status == ReadingStatus.active;
  bool get isCompleted => status == ReadingStatus.completed;
  bool get isPending => status == ReadingStatus.pending;
  bool get isCancelled => status == ReadingStatus.cancelled;

  String get formattedDuration {
    if (duration == null) return '0 min';
    
    final minutes = duration!.inMinutes;
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = duration!.inHours;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  String get formattedCost {
    return '\$${(totalCost ?? 0.0).toStringAsFixed(2)}';
  }

  String get readingTypeDisplay {
    switch (type) {
      case ReadingType.chat:
        return 'Chat Reading';
      case ReadingType.phone:
        return 'Phone Reading';
      case ReadingType.video:
        return 'Video Reading';
    }
  }

  String get statusDisplay {
    switch (status) {
      case ReadingStatus.pending:
        return 'Pending';
      case ReadingStatus.active:
        return 'Active';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.cancelled:
        return 'Cancelled';
    }
  }
}