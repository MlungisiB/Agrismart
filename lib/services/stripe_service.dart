// services/stripe_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:agrismart/const.dart';

class StripeService {
  Map<String, dynamic>? paymentIntentData;

  Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount, // Amount in cents
        'currency': currency,
        'payment_method_types[]': 'card', // Explicitly request card payments
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey', // <--- YOUR SECRET KEY IS EXPOSED HERE!
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode != 200) {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error']['message'] ?? 'Unknown Stripe API error';
        debugPrint('Stripe API Error creating PaymentIntent: ${errorMessage} (Status: ${response.statusCode}, Body: ${response.body})');
        throw Exception('Stripe API Error: $errorMessage (Status: ${response.statusCode})');
      }

      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Error creating payment intent (client-side): $err');
      throw Exception('Failed to create payment intent: $err');
    }
  }

  Future<bool> makePayment(BuildContext context, {required double amount, required String currency}) async {
    try {
      paymentIntentData = await _createPaymentIntent(
        (amount * 100).toInt().toString(), // Convert to cents
        currency,
      );


      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'AgriSmart (Pty) Ltd', // Your business name
          allowsDelayedPaymentMethods: true,
          style: ThemeMode.light, // Or ThemeMode.dark
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );
      return true; // Indicate success
    } on StripeException catch (e) {
      String errorMessage = 'Payment failed.';
      if (e.error.localizedMessage != null && e.error.localizedMessage!.isNotEmpty) {
        errorMessage = 'Payment failed: ${e.error.localizedMessage}';
      } else if (e.error.message != null && e.error.message!.isNotEmpty) {
        errorMessage = 'Payment failed: ${e.error.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      debugPrint('Stripe Payment Error: ${e.error.code} - ${e.error.message} - ${e.error.localizedMessage}');
      return false; // Indicate failure
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      debugPrint('Unexpected Payment Error: $e');
      return false; // Indicate failure
    }
  }
}