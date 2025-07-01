// momo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class MomoService {
  final String _baseUrl = 'https://hqsttrggzulpizedagku.supabase.co';

  Future<String?> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/momo/initiate-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'currency': 'SZL',
        'phoneNumber': phoneNumber,
        'orderId': orderId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['transactionId'];
    } else {
      throw Exception('Payment initiation failed: ${response.body}');
    }
  }

  Future<String> checkPaymentStatus(String transactionId) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/momo/payment-status/$transactionId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status']?.toUpperCase() ?? 'UNKNOWN';
    } else {
      throw Exception('Status check failed: ${response.body}');
    }
  }
}
