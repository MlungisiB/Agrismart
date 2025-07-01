// screens/order_details_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrismart/model/order.dart';
import 'package:agrismart/model/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define a type for your callback for clarity. This will be passed from OrdersPage.
typedef OrderRefreshCallback = void Function();

class OrderDetailsPage extends StatefulWidget {
  final Order order;
  final OrderRefreshCallback? onOrderUpdated;
  final String? originatingTabStatus;

  const OrderDetailsPage({
    super.key,
    required this.order,
    this.onOrderUpdated,
    this.originatingTabStatus,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final currencyFormat = NumberFormat.currency(locale: 'en_SZ', symbol: 'E');
  late Order _currentOrder; // This will hold the mutable order data
  // Separate loading flags for each button
  bool _isPicking = false;
  bool _isDelivering = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order; // Initialize with the order passed from OrdersPage
  }

  // Function to update order status in Supabase
  Future<void> _updateOrderStatus(String newStatus, {bool isPickingButton = false, bool isDeliveringButton = false}) async {
    if (!mounted) return;

    // Set loading state for the specific button
    setState(() {
      if (isPickingButton) {
        _isPicking = true;
      } else if (isDeliveringButton) {
        _isDelivering = true;
      }
    });

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', _currentOrder.id)
          .select(); // Use .select() to get the updated row data

      if (!mounted) return;

      if (response.isNotEmpty) {
        final updatedOrderData = response[0];
        setState(() {
          // Update the _currentOrder state with the new status from Supabase
          _currentOrder = Order(
            id: updatedOrderData['id'] as String,
            userId: updatedOrderData['user_id'] as String?,
            items: _currentOrder.items, // Keep existing items, as they don't change
            date: DateTime.parse(updatedOrderData['created_at'] as String),
            status: updatedOrderData['status'] as String?, // This is the updated status
            grandTotalAmount: (updatedOrderData['grand_total_amount'] as num?)?.toDouble(),
            deliveryAddress: updatedOrderData['delivery_address'] as Map<String, dynamic>?,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus!')),
        );

        // Call the callback to notify the parent OrdersPage
        widget.onOrderUpdated?.call();

      } else {
        throw Exception('Failed to get updated order data after status change.');
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      debugPrint('Supabase error updating order status: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.message}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      debugPrint('Unexpected error updating order status: $e');
      debugPrintStack(stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      // Reset loading state for the specific button
      setState(() {
        if (isPickingButton) {
          _isPicking = false;
        } else if (isDeliveringButton) {
          _isDelivering = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define if the order's current status is a 'final' state
    final bool isFinalStatus = _currentOrder.status == 'Delivered' || _currentOrder.status == 'Completed';

    // Define if buttons should be hidden because the order came from the 'Completed' tab
    final bool hideButtonsBecauseOfTab = widget.originatingTabStatus == 'Completed';

    // Overall decision: show buttons only if not a final status AND not from the 'Completed' tab
    final bool shouldShowActionButtons = !isFinalStatus && !hideButtonsBecauseOfTab;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_currentOrder.id.substring(0, 8)}...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Order Confirmed!'),
            const SizedBox(height: 8),
            Text(
              'Thank you for your order. Your order ID is ${_currentOrder.id}.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(context, 'Order ID:', _currentOrder.id),
                    _buildDetailRow(context, 'Date Placed:', DateFormat.yMMMd().add_jm().format(_currentOrder.date)),
                    _buildDetailRow(context, 'Status:', _currentOrder.status ?? 'Processing'),
                    if (_currentOrder.grandTotalAmount != null)
                      _buildDetailRow(context, 'Order Total:', currencyFormat.format(_currentOrder.grandTotalAmount)),
                    if (_currentOrder.deliveryAddress != null && _currentOrder.deliveryAddress!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Delivery Address:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        _formatAddress(_currentOrder.deliveryAddress!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Items in this Order'),
            const SizedBox(height: 8),
            if (_currentOrder.items.isEmpty)
              const Text('No items found in this order (this should not happen).')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentOrder.items.length,
                itemBuilder: (context, index) {
                  final orderItem = _currentOrder.items[index];
                  final product = orderItem.product;
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                      )
                          : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(orderItem.productNameAtPurchase),
                      subtitle: Text(
                          '${currencyFormat.format(orderItem.priceAtPurchase)} x ${orderItem.quantity} = ${currencyFormat.format(orderItem.priceAtPurchase * orderItem.quantity)}'),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Conditional rendering of action buttons based on status and originating tab
            if (shouldShowActionButtons)
              Row(
                children: [
                  // 'Mark as Picked' button
                  if (_currentOrder.status == 'Processing')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isPicking
                            ? null // Disable only this button if it's loading
                            : () => _updateOrderStatus('Picked', isPickingButton: true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isPicking
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Mark as Picked', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  // Add spacing between buttons if both are present
                  if (_currentOrder.status == 'Processing')
                    const SizedBox(width: 10),

                  // 'Mark as Delivered' button
                  if (_currentOrder.status == 'Processing' || _currentOrder.status == 'Picked')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isDelivering
                            ? null // Disable only this button if it's loading
                            : () => _updateOrderStatus('Delivered', isDeliveringButton: true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.green,
                        ),
                        child: _isDelivering
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Mark as Delivered', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              )
            else if (hideButtonsBecauseOfTab) // Only show a message if buttons are explicitly hidden due to tab origin
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'This order is in a final state and no further actions are available.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 3,
              child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ));
  }

  String _formatAddress(Map<String, dynamic> addressMap) {
    return [
      addressMap['line1'],
      addressMap['line2'],
      addressMap['city'],
      addressMap['town'],
      addressMap['country'],
    ].where((s) => s != null && s.toString().isNotEmpty).join(', ');
  }
}