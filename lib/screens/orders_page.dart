// screens/orders_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrismart/model/order.dart';
import 'package:agrismart/widgets/order_item.dart';
import 'package:agrismart/model/product.dart';
import 'package:agrismart/screens/order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required String userEmail});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<String> _tabs = ["Processing", "Picked", "Delivered", "Completed"];

  final Map<String, List<Order>> _ordersByStatus = {};
  final Map<String, bool> _isLoadingByStatus = {};
  final Map<String, String?> _errorByStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    for (var status in _tabs) {
      _ordersByStatus[status] = [];
      _isLoadingByStatus[status] = false;
      _errorByStatus[status] = null;
    }
    _fetchOrdersForStatus(_tabs[_tabController.index]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, refreshing orders for tab: ${_tabs[_tabController.index]}');
      _fetchOrdersForStatus(_tabs[_tabController.index]);
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final selectedStatus = _tabs[_tabController.index];
    _fetchOrdersForStatus(selectedStatus);
  }

  Future<void> _fetchOrdersForStatus(String status) async {
    if (!mounted) return;

    setState(() {
      _isLoadingByStatus[status] = true;
      _errorByStatus[status] = null;
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingByStatus[status] = false;
        _errorByStatus[status] = "User not authenticated. Please log in.";
        _ordersByStatus[status] = [];
      });
      return;
    }

    try {
      var filterBuilder = Supabase.instance.client
          .from('orders')
          .select('''
            id,
            user_id,
            created_at,
            status,
            grand_total_amount,
            delivery_address,
            order_items (
              product_id,
              quantity,
              price_at_purchase,
              product_name_at_purchase,
              products!inner (
                id,
                name,
                sellingprice,
                image_path,
                description,
                category
              )
            )
          ''');

      filterBuilder = filterBuilder.eq('user_id', currentUser.id);

      // Apply status filter
      if (status == "Completed") {
        String orConditions = [
          'status.eq.Picked',
          'status.eq.Delivered',
          'status.eq.Completed'
        ].join(',');
        filterBuilder = filterBuilder.or(orConditions);
      } else {
        filterBuilder = filterBuilder.eq('status', status);
      }

      // Conditional Sorting Logic: Newest first for 'Completed', Oldest first for others
      bool ascendingSort = true;
      if (status == "Completed") {
        ascendingSort = false; // Newest first for Completed
      }
      final response = await filterBuilder.order('created_at', ascending: ascendingSort);

      if (!mounted) return;

      final List<Order> fetchedOrders = response.map<Order>((orderData) {
        final List<OrderItemData> orderItems =
            (orderData['order_items'] as List<dynamic>?)?.map((itemData) {
              final productDataFromServer = itemData['products'];
              final priceAtPurchase = (itemData['price_at_purchase'] as num?)?.toDouble() ?? 0.0;
              final productNameAtPurchase = itemData['product_name_at_purchase']?.toString() ?? 'N/A';

              Product product;
              if (productDataFromServer != null && productDataFromServer is Map<String, dynamic>) {
                product = Product.fromMap({
                  'product_id': productDataFromServer['id'],
                  'name': productDataFromServer['name'],
                  'price': (productDataFromServer['sellingprice'] as num?)?.toDouble() ?? 0.0,
                  'image_url': productDataFromServer['image_path'],
                  'description': productDataFromServer['description'],
                  'category': productDataFromServer['category'],
                });
              } else {
                product = Product(
                  id: itemData['product_id']?.toString() ?? 'unknown_product_id',
                  name: productNameAtPurchase,
                  price: priceAtPurchase,
                  imageUrl: '',
                  description: null,
                  category: null,
                );
                debugPrint("Warning: productDataFromServer was null for order_item. Product_id: ${itemData['product_id']}");
              }

              return OrderItemData(
                product: product,
                quantity: (itemData['quantity'] as int?) ?? 0,
                priceAtPurchase: priceAtPurchase,
                productNameAtPurchase: productNameAtPurchase,
              );
            }).toList() ?? [];

        return Order(
          id: orderData['id'] as String,
          userId: orderData['user_id'] as String?,
          items: orderItems,
          date: DateTime.parse(orderData['created_at'] as String),
          status: orderData['status'] as String?,
          grandTotalAmount: (orderData['grand_total_amount'] as num?)?.toDouble(),
          deliveryAddress: orderData['delivery_address'] as Map<String, dynamic>?,
        );
      }).toList();

      setState(() {
        _ordersByStatus[status] = fetchedOrders;
        _isLoadingByStatus[status] = false;
      });

    } on PostgrestException catch (e) {
      debugPrint('Supabase error fetching orders for status $status: ${e.message}');
      if (!mounted) return;
      setState(() {
        _isLoadingByStatus[status] = false;
        _errorByStatus[status] = "Failed to load orders: ${e.message}";
        _ordersByStatus[status] = [];
      });
    } catch (e, stackTrace) {
      debugPrint('Unexpected error fetching orders for status $status: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoadingByStatus[status] = false;
        _errorByStatus[status] = "An unexpected error occurred. Please try again.";
        _ordersByStatus[status] = [];
      });
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    if (!mounted) return;

    final oldStatus = order.status;

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', order.id)
          .select();

      if (response.isEmpty) {
        throw Exception('Order not found or not updated.');
      }

      if (oldStatus != null) {
        await _fetchOrdersForStatus(oldStatus);
      }
      await _fetchOrdersForStatus(newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${order.id} successfully marked as $newStatus!')),
      );
      debugPrint('Order ${order.id} status updated from $oldStatus to $newStatus.');

    } on PostgrestException catch (e) {
      debugPrint('Supabase error updating order status: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.message}', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error updating order status: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTabContent(String status) {
    final isLoading = _isLoadingByStatus[status] ?? true;
    final error = _errorByStatus[status];
    final orders = _ordersByStatus[status] ?? [];

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _fetchOrdersForStatus(status),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ));
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No orders found for this status.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _fetchOrdersForStatus(status),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderItem(
          order: order,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(
                  order: order,
                  onOrderUpdated: () {
                    _fetchOrdersForStatus(_tabs[_tabController.index]);
                  },
                  // Pass the current tab's status to OrderDetailsPage
                  originatingTabStatus: status,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((status) => _buildTabContent(status)).toList(),
      ),
    );
  }
}