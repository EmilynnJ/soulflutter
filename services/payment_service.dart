import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../supabase/supabase_config.dart';
import '../services/enhanced_auth_service.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _publishableKey = 'pk_test_STRIPE_PUBLISHABLE_KEY'; // Replace with actual key
  static const String _secretKey = 'sk_test_STRIPE_SECRET_KEY'; // Replace with actual key

  static bool _isInitialized = false;

  // Initialize Stripe
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
    _isInitialized = true;
  }

  // Add funds to user account
  static Future<bool> addFundsToAccount({
    required double amount,
    required String currency,
  }) async {
    try {
      await initialize();
      
      final user = EnhancedAuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: (amount * 100).round(), // Convert to cents
        currency: currency,
        customerId: user.id,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'SoulSeer',
          customerId: user.id,
          setupIntentClientSecret: paymentIntent['setup_intent_client_secret'],
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If successful, update user balance
      await EnhancedAuthService.addFunds(amount);

      // Record transaction
      await _recordTransaction(
        userId: user.id,
        amount: amount,
        type: 'top_up',
        status: 'completed',
        stripePaymentIntentId: paymentIntent['id'],
        description: 'Account balance top-up',
      );

      return true;
    } catch (e) {
      print('Payment failed: $e');
      return false;
    }
  }

  // Process reading session payment
  static Future<bool> processReadingPayment({
    required String sessionId,
    required double amount,
    required String readerId,
    required String clientId,
  }) async {
    try {
      final user = EnhancedAuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Calculate earnings split (70% to reader, 30% to platform)
      final readerEarnings = amount * 0.7;
      final platformFee = amount * 0.3;

      // Record payment transaction for client
      await _recordTransaction(
        userId: clientId,
        sessionId: sessionId,
        amount: -amount,
        type: 'payment',
        status: 'completed',
        description: 'Payment for reading session',
      );

      // Record payout transaction for reader
      await _recordTransaction(
        userId: readerId,
        sessionId: sessionId,
        amount: readerEarnings,
        type: 'payout',
        status: 'completed',
        description: 'Earnings from reading session',
      );

      // Update reader earnings in profile
      await _updateReaderEarnings(readerId, readerEarnings);

      return true;
    } catch (e) {
      print('Reading payment failed: $e');
      return false;
    }
  }

  // Create Stripe payment intent
  static Future<Map<String, dynamic>> _createPaymentIntent({
    required int amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'customer': customerId,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment intent creation failed: $e');
    }
  }

  // Record transaction in database
  static Future<void> _recordTransaction({
    required String userId,
    String? sessionId,
    required double amount,
    required String type,
    required String status,
    String? stripePaymentIntentId,
    required String description,
  }) async {
    try {
      await SupabaseConfig.client?.from('transactions').insert({
        'user_id': userId,
        'session_id': sessionId,
        'type': type,
        'amount': amount,
        'status': status,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to record transaction: $e');
    }
  }

  // Update reader earnings
  static Future<void> _updateReaderEarnings(String readerId, double earnings) async {
    try {
      // Get current reader profile
      final response = await SupabaseConfig.client
          ?.from('reader_profiles')
          .select('total_earnings, pending_earnings')
          .eq('user_id', readerId)
          .single();

      if (response != null) {
        final currentTotalEarnings = (response['total_earnings'] as num?)?.toDouble() ?? 0.0;
        final currentPendingEarnings = (response['pending_earnings'] as num?)?.toDouble() ?? 0.0;

        await SupabaseConfig.client?.from('reader_profiles').update({
          'total_earnings': currentTotalEarnings + earnings,
          'pending_earnings': currentPendingEarnings + earnings,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', readerId);
      }
    } catch (e) {
      print('Failed to update reader earnings: $e');
    }
  }

  // Process reader payout
  static Future<bool> processReaderPayout({
    required String readerId,
    required double amount,
  }) async {
    try {
      // In a real implementation, this would integrate with Stripe Connect
      // For now, we'll just update the pending earnings
      
      final response = await SupabaseConfig.client
          ?.from('reader_profiles')
          .select('pending_earnings')
          .eq('user_id', readerId)
          .single();

      if (response != null) {
        final currentPendingEarnings = (response['pending_earnings'] as num?)?.toDouble() ?? 0.0;
        
        if (currentPendingEarnings >= amount) {
          await SupabaseConfig.client?.from('reader_profiles').update({
            'pending_earnings': currentPendingEarnings - amount,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', readerId);

          // Record payout transaction
          await _recordTransaction(
            userId: readerId,
            amount: amount,
            type: 'payout',
            status: 'completed',
            description: 'Reader earnings payout',
          );

          return true;
        } else {
          throw Exception('Insufficient pending earnings');
        }
      }
      
      return false;
    } catch (e) {
      print('Payout failed: $e');
      return false;
    }
  }

  // Get user transaction history
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await SupabaseConfig.client
          ?.from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Failed to get transaction history: $e');
      return [];
    }
  }

  // Create Stripe customer
  static Future<String?> createStripeCustomer({
    required String email,
    required String name,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
          'metadata[user_id]': userId,
        },
      );

      if (response.statusCode == 200) {
        final customer = json.decode(response.body);
        return customer['id'];
      }
      return null;
    } catch (e) {
      print('Failed to create Stripe customer: $e');
      return null;
    }
  }

  // Setup payment methods
  static Future<bool> setupPaymentMethod() async {
    try {
      await initialize();
      
      final user = EnhancedAuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create setup intent
      final setupIntent = await _createSetupIntent(customerId: user.id);

      // Initialize payment sheet for setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: setupIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'SoulSeer',
          customerId: user.id,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      return true;
    } catch (e) {
      print('Setup payment method failed: $e');
      return false;
    }
  }

  // Create setup intent for saving payment methods
  static Future<Map<String, dynamic>> _createSetupIntent({
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/setup_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create setup intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Setup intent creation failed: $e');
    }
  }

  // Handle subscription payments (for premium features)
  static Future<bool> createSubscription({
    required String customerId,
    required String priceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
          'payment_behavior': 'default_incomplete',
          'expand[]': 'latest_invoice.payment_intent',
        },
      );

      if (response.statusCode == 200) {
        final subscription = json.decode(response.body);
        return subscription['status'] == 'active';
      }
      return false;
    } catch (e) {
      print('Subscription creation failed: $e');
      return false;
    }
  }

  // Cancel subscription
  static Future<bool> cancelSubscription({required String subscriptionId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Subscription cancellation failed: $e');
      return false;
    }
  }

  // Get payment methods for customer
  static Future<List<Map<String, dynamic>>> getPaymentMethods({
    required String customerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_methods?customer=$customerId&type=card'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Failed to get payment methods: $e');
      return [];
    }
  }
}