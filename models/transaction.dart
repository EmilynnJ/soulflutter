class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'top_up', 'reading_payment', 'refund', 'payout'
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final String description;
  final String? stripePaymentIntentId;
  final String? sessionId;
  final String? readerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    this.stripePaymentIntentId,
    this.sessionId,
    this.readerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      sessionId: json['session_id'] as String?,
      readerId: json['reader_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'description': description,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'session_id': sessionId,
      'reader_id': readerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? status,
    String? description,
    String? stripePaymentIntentId,
    String? sessionId,
    String? readerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      sessionId: sessionId ?? this.sessionId,
      readerId: readerId ?? this.readerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  bool get isCredit => type == 'top_up' || type == 'refund';
  bool get isDebit => type == 'reading_payment' || type == 'payout';
}