import 'dart:convert';
import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../../shared/widgets/product_image.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../models/order_model.dart';

class OrdersView extends ConsumerStatefulWidget {
  final VoidCallback? onBackToHome;

  const OrdersView({super.key, this.onBackToHome});

  @override
  ConsumerState<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<OrderModel> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final authState = ref.read(authControllerProvider);
    final email = authState.user?.email.trim().toLowerCase();

    // STRICT ISOLATION: Unauthenticated or guest users must NEVER fetch or see orders.
    if (email == null ||
        email.isEmpty ||
        authState.isGuest ||
        !authState.isAuthenticated) {
      if (mounted) {
        setState(() {
          _allOrders = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final serverOrders = await client.order.getOrders(
        customerEmail: email,
      );

      final liveOrders = serverOrders.map(_mapStoreOrderToModel).toList();
      if (mounted) {
        setState(() {
          _allOrders = liveOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[OrdersView] Backend live orders fetch notice: $e');
      if (mounted) {
        setState(() {
          _allOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  OrderModel _mapStoreOrderToModel(StoreOrder so) {
    List<OrderItem> items = [];
    final homeProducts = ref.read(homeControllerProvider).allProducts;

    try {
      final decoded = jsonDecode(so.itemsJson) as List;
      for (final it in decoded) {
        if (it is Map<String, dynamic>) {
          final itemId = it['id']?.toString() ?? '';
          final itemName = it['name']?.toString() ?? 'Al-Nur Modest Item';
          String effectiveImage = it['imageUrl']?.toString() ?? '';

          // If image is missing or is the misleading hardcoded abaya image, resolve from live catalog
          if (effectiveImage.isEmpty || effectiveImage.contains('photo-1583391733956')) {
            final match = homeProducts.where((p) =>
              p.id == itemId ||
              p.name.toLowerCase().trim() == itemName.toLowerCase().trim() ||
              (itemName.isNotEmpty && p.name.toLowerCase().contains(itemName.toLowerCase())) ||
              (p.name.isNotEmpty && itemName.toLowerCase().contains(p.name.toLowerCase()))
            ).firstOrNull;
            if (match != null) {
              effectiveImage = match.imageUrl;
            } else {
              effectiveImage = '';
            }
          }

          items.add(
            OrderItem(
              name: itemName,
              category: it['category']?.toString() ?? 'Modesty Collection',
              quantity: (it['quantity'] as num?)?.toInt() ?? 1,
              size: it['selectedSize']?.toString() ?? '56',
              color: it['selectedColor']?.toString() ?? 'Default',
              price: (it['price'] as num?)?.toDouble() ?? 0.0,
              imageUrl: effectiveImage,
            ),
          );
        }
      }
    } catch (_) {}

    if (items.isEmpty) {
      items.add(
        OrderItem(
          name: 'Al-Nur Modest Item',
          category: 'Couture',
          quantity: 1,
          size: 'Standard',
          color: 'Default',
          price: so.totalAmount,
          imageUrl: '',
        ),
      );
    }

    OrderStatus status = OrderStatus.processing;
    final fStatus =
        so.fulfillmentStatus.toLowerCase().trim().replaceAll(' ', '_');
    if (fStatus.contains('cancel')) {
      status = OrderStatus.cancelled;
    } else if (fStatus.contains('deliver') || fStatus.contains('completed')) {
      status = OrderStatus.delivered;
    } else if (fStatus.contains('out_for_delivery') ||
        fStatus.contains('transit')) {
      status = OrderStatus.outForDelivery;
    } else if (fStatus.contains('ship') || fStatus.contains('dispatch')) {
      status = OrderStatus.shipped;
    } else {
      status = OrderStatus.processing;
    }

    final subtotal = so.totalAmount > 2500
        ? so.totalAmount - 2500
        : so.totalAmount;
    final shippingFee = so.totalAmount > 2500 ? 2500.0 : 0.0;
    final tracking = 'ALN-TRK-${so.orderRef.replaceAll('ALN-', '')}';

    return OrderModel(
      id: so.orderRef,
      orderDate: so.createdAt,
      status: status,
      trackingNumber: tracking,
      deliveryAddress: so.shippingAddress,
      estimatedDelivery: status == OrderStatus.delivered
          ? 'Delivered'
          : status == OrderStatus.outForDelivery
              ? 'Arriving Today via Express Courier'
              : 'Estimated 2-3 Days via Express Courier',
      subtotal: subtotal,
      shippingFee: shippingFee,
      totalAmount: so.totalAmount,
      items: items,
      timeline: [
        OrderTimelineStep(
          title: 'Order Placed & Confirmed',
          subtitle:
              'Payment: ${so.paymentStatus.toUpperCase()} (Ref: ${so.paymentReference ?? so.orderRef})',
          date:
              '${so.createdAt.day}/${so.createdAt.month}/${so.createdAt.year}',
          isCompleted: true,
        ),
        OrderTimelineStep(
          title: 'Processing & Handcrafted Tailoring',
          subtitle: 'Handcrafted according to modesty guidelines',
          date: status != OrderStatus.cancelled ? 'Completed' : 'Cancelled',
          isCompleted: status != OrderStatus.cancelled,
          isCurrent: status == OrderStatus.processing,
        ),
        OrderTimelineStep(
          title: 'Shipped & Handed to Courier',
          subtitle: 'Waybill Track ID: $tracking',
          date: (status == OrderStatus.shipped ||
                  status == OrderStatus.outForDelivery ||
                  status == OrderStatus.delivered)
              ? 'Shipped'
              : 'Pending',
          isCompleted: (status == OrderStatus.shipped ||
              status == OrderStatus.outForDelivery ||
              status == OrderStatus.delivered),
          isCurrent: status == OrderStatus.shipped,
        ),
        OrderTimelineStep(
          title: 'Out for Delivery',
          subtitle: 'Logistics rider in your delivery zone',
          date: (status == OrderStatus.outForDelivery ||
                  status == OrderStatus.delivered)
              ? 'In Delivery'
              : 'Pending',
          isCompleted: (status == OrderStatus.outForDelivery ||
              status == OrderStatus.delivered),
          isCurrent: status == OrderStatus.outForDelivery,
        ),
        OrderTimelineStep(
          title: 'Delivered',
          subtitle: 'Delivered to ${so.customerName}',
          date: status == OrderStatus.delivered ? 'Delivered' : 'Pending',
          isCompleted: status == OrderStatus.delivered,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> get _activeOrders => _allOrders
      .where(
        (o) =>
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipped ||
            o.status == OrderStatus.outForDelivery,
      )
      .toList();

  List<OrderModel> get _completedOrders =>
      _allOrders.where((o) => o.status == OrderStatus.delivered).toList();

  List<OrderModel> get _cancelledOrders =>
      _allOrders.where((o) => o.status == OrderStatus.cancelled).toList();

  String _formatOrderDateTime(DateTime date) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(date);

    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return 'Today, $timeStr';
    } else if (now.year == date.year &&
        now.month == date.month &&
        (now.day - date.day == 1)) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('d MMM yyyy').format(date)}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically re-fetch or clear orders whenever user signs in, signs out, or switches accounts
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user?.email != next.user?.email ||
          previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isGuest != next.isGuest) {
        _fetchOrders();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: 'Back to Home',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Modest Orders',
              style: AppTextStyles.productTitle.copyWith(fontSize: 18),
            ),
            Text(
              '${_allOrders.length} total orders across Al-Nur collections',
              style: AppTextStyles.brandSubtitle.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Support',
            onPressed: () => _showSupportDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'Active (${_activeOrders.length})'),
            Tab(text: 'Completed (${_completedOrders.length})'),
            Tab(text: 'Cancelled (${_cancelledOrders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(_activeOrders, isCurrentTabActive: true),
                  _buildOrdersList(_completedOrders),
                  _buildOrdersList(_cancelledOrders),
                ],
              ),
            ),
    );
  }

  Widget _buildOrdersList(
    List<OrderModel> orders, {
    bool isCurrentTabActive = false,
  }) {
    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Orders Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your modest clothing orders will appear here once placed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                    label: const Text('Explore Modest Collections'),
                    onPressed: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatOrderDateTime(order.orderDate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: order.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.status.label,
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImage(
                          imageUrl: item.imageUrl,
                          width: 64,
                          height: 64,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Size: ${item.size} • ${item.color} • Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₦${item.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: AppColors.border),

                // Order Meta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • Free Scenting',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Total: ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: '₦${order.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Active Buttons Row
                Row(
                  children: [
                    // Primary Action
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          order.status == OrderStatus.delivered
                              ? Icons.refresh_rounded
                              : Icons.local_shipping_outlined,
                          size: 16,
                        ),
                        label: Text(
                          order.status == OrderStatus.delivered
                              ? 'Buy Again'
                              : 'Track Order',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          if (order.status == OrderStatus.delivered) {
                            _handleBuyAgain(order);
                          } else {
                            _showTrackingModal(order);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Secondary Action
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          order.status == OrderStatus.delivered
                              ? Icons.star_border_rounded
                              : Icons.receipt_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          order.status == OrderStatus.delivered
                              ? 'Review Item'
                              : 'View Invoice',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          if (order.status == OrderStatus.delivered) {
                            _showReviewDialog(order);
                          } else {
                            _showInvoiceModal(order);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackingModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Order Tracking',
                        style: AppTextStyles.productTitle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tracking ID: ${order.trackingNumber}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Placed: ${_formatOrderDateTime(order.orderDate)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.estimatedDelivery,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Timeline',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: order.timeline.length,
                itemBuilder: (context, index) {
                  final step = order.timeline[index];
                  final isLast = index == order.timeline.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: step.isCompleted
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              border: step.isCurrent
                                  ? Border.all(color: AppColors.gold, width: 3)
                                  : null,
                            ),
                            child: Center(
                              child: Icon(
                                step.isCompleted ? Icons.check : Icons.circle,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: step.isCompleted
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontWeight: step.isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: step.isCompleted
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: const Text('Call Courier Driver'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Connecting to Ibrahim (+234 803 123 4567)...',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Al-Nur Official Invoice',
                        style: AppTextStyles.productTitle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Invoice #: INV-${order.id}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Date: ${_formatOrderDateTime(order.orderDate)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            const Text(
              'Itemized Breakdown',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Size: ${item.size} • Qty: ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₦${(item.price * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '₦${order.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Standard Doorstep Delivery',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '₦${order.shippingFee.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Islamic Oud Scenting & Gift Box',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        'FREE',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '₦${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download PDF Receipt'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Invoice ${order.id} downloaded to your device',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(OrderModel order) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Rate & Review',
            style: AppTextStyles.productTitle.copyWith(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How was the quality and modest fit of your ${order.items.first.name}?',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.starAmber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText:
                      'Share fabric texture, drape, and sizing thoughts...',
                  hintStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Later',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Jazakallahu Khair! Your review was submitted.',
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBuyAgain(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${order.items.length} items from ${order.id} back to your cart!',
        ),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.gold,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Al-Nur Concierge Support'),
        content: const Text(
          'Need help with tailoring, size exchange, or delivery updates? Our modest fashion team is available 24/7.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Chat with Concierge'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connecting to Al-Nur Concierge...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
