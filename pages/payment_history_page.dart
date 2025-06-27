import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/transaction.dart';
import '../services/enhanced_auth_service.dart';
import '../widgets/mystical_button.dart';
import '../utils/soul_seer_colors.dart';
import 'dart:math' as math;

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage>
    with TickerProviderStateMixin {
  UserModel? _currentUser;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';
  
  late AnimationController _starsController;
  late AnimationController _fadeController;
  late Animation<double> _starsAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadPaymentHistory();
    _starsController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      _currentUser = EnhancedAuthService.currentUserProfile;
      
      if (_currentUser == null) {
        setState(() {
          _errorMessage = 'Please log in to view your payment history';
          _isLoading = false;
        });
        return;
      }

      // Load user\'s transactions
      final transactions = await EnhancedAuthService.getUserTransactions(_currentUser!.id);
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payment history: $e';
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'all') return _transactions;
    return _transactions.where((t) => t.type == _selectedFilter).toList();
  }

  double get _totalSpent {
    return _transactions
        .where((t) => t.type == 'reading_payment' && t.status == 'completed')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalAdded {
    return _transactions
        .where((t) => t.type == 'top_up' && t.status == 'completed')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment History',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: SoulSeerColors.mysticalPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: SoulSeerColors.mysticalPink,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A0033),
                Colors.black,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SoulSeerColors.mysticalPink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: SoulSeerColors.mysticalPink),
            color: Colors.black,
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, color: SoulSeerColors.mysticalPink, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'All Transactions',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    if (_selectedFilter == 'all')
                      const Spacer()
                    else
                      const SizedBox(),
                    if (_selectedFilter == 'all')
                      Icon(Icons.check, color: SoulSeerColors.cosmicGold, size: 20),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'top_up',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Fund Additions',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    if (_selectedFilter == 'top_up')
                      const Spacer()
                    else
                      const SizedBox(),
                    if (_selectedFilter == 'top_up')
                      Icon(Icons.check, color: SoulSeerColors.cosmicGold, size: 20),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reading_payment',
                child: Row(
                  children: [
                    Icon(Icons.payment, color: SoulSeerColors.cosmicGold, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Reading Payments',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    if (_selectedFilter == 'reading_payment')
                      const Spacer()
                    else
                      const SizedBox(),
                    if (_selectedFilter == 'reading_payment')
                      Icon(Icons.check, color: SoulSeerColors.cosmicGold, size: 20),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refund',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Refunds',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    if (_selectedFilter == 'refund')
                      const Spacer()
                    else
                      const SizedBox(),
                    if (_selectedFilter == 'refund')
                      Icon(Icons.check, color: SoulSeerColors.cosmicGold, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF1A0033),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated stars background
            ...List.generate(60, (index) {
              return AnimatedBuilder(
                animation: _starsAnimation,
                builder: (context, child) {
                  final random = (index * 9999) % 1000 / 1000;
                  final x = (index * 37) % MediaQuery.of(context).size.width;
                  final y = (index * 73) % MediaQuery.of(context).size.height;
                  final opacity = (0.3 + 0.7 * ((index * 127) % 100) / 100) * 
                                 (0.5 + 0.5 * (1 + math.sin(_starsAnimation.value * 2 * math.pi + random * 2 * math.pi)) / 2);
                  
                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Main content
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: SoulSeerColors.mysticalPink,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              MysticalButton(
                text: 'Retry',
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadPaymentHistory();
                },
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final theme = Theme.of(context);
    final filteredTransactions = _filteredTransactions;
    
    if (filteredTransactions.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SoulSeerColors.mysticalPink.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 80,
                  color: SoulSeerColors.mysticalPink,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Transactions Yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: SoulSeerColors.mysticalPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your payment history will appear here once you make your first transaction.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                MysticalButton(
                  text: 'Add Funds',
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to add funds
                  },
                  icon: Icons.add_circle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderSection();
          }
          
          final transaction = filteredTransactions[index - 1];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoulSeerColors.mysticalPink.withOpacity(0.1),
            SoulSeerColors.cosmicGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: SoulSeerColors.mysticalPink,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: SoulSeerColors.mysticalPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Added',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_totalAdded.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SoulSeerColors.cosmicGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: SoulSeerColors.cosmicGold.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: SoulSeerColors.cosmicGold,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Spent',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SoulSeerColors.cosmicGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_totalSpent.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: SoulSeerColors.cosmicGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredTransactions.length} Transaction${_filteredTransactions.length != 1 ? 's' : ''} ${_selectedFilter != 'all' ? '(Filtered)' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor(transaction.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(transaction.type),
                        color: _getTypeColor(transaction.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTypeDisplay(transaction.type),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                        Text(
                          '${transaction.type == 'top_up' || transaction.type == 'refund' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: transaction.type == 'top_up' || transaction.type == 'refund' 
                                ? Colors.green 
                                : SoulSeerColors.cosmicGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(transaction.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusDisplay(transaction.status),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(transaction.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(transaction.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    if (transaction.stripePaymentIntentId != null)
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Card',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'top_up':
        return Icons.add_circle;
      case 'reading_payment':
        return Icons.payment;
      case 'refund':
        return Icons.refresh;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'top_up':
        return Colors.green;
      case 'reading_payment':
        return SoulSeerColors.cosmicGold;
      case 'refund':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplay(String type) {
    switch (type) {
      case 'top_up':
        return 'Fund Addition';
      case 'reading_payment':
        return 'Reading Payment';
      case 'refund':
        return 'Refund';
      default:
        return 'Transaction';
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTransactionDetailsSheet(transaction),
    );
  }

  Widget _buildTransactionDetailsSheet(Transaction transaction) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: SoulSeerColors.mysticalPink.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: SoulSeerColors.mysticalPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDetailRow('Type', _getTypeDisplay(transaction.type)),
                  _buildDetailRow('Amount', '\$${transaction.amount.toStringAsFixed(2)}'),
                  _buildDetailRow('Status', _getStatusDisplay(transaction.status)),
                  _buildDetailRow('Date & Time', dateFormat.format(transaction.createdAt)),
                  _buildDetailRow('Description', transaction.description),
                  
                  if (transaction.stripePaymentIntentId != null)
                    _buildDetailRow('Payment ID', transaction.stripePaymentIntentId!),
                  
                  if (transaction.sessionId != null)
                    _buildDetailRow('Session ID', transaction.sessionId!),
                    
                  const SizedBox(height: 24),
                  
                  if (transaction.status == 'failed')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Transaction Failed',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This transaction could not be processed. Please contact support if you have any questions.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}