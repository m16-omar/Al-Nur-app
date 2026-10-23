import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/order_model.dart';

class OrdersView extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const OrdersView({super.key, this.onBackToHome});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<OrderModel> _allOrders = [
    OrderModel(
      id: 'ALN-84920',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.inTransit,
      trackingNumber: 'ALN-TRK-9920148',
      deliveryAddress: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos',
      estimatedDelivery: 'Today by 4:30 PM',
      subtotal: 37000,
      shippingFee: 2500,
      totalAmount: 39500,
      items: const [
        OrderItem(
          name: 'Dubai Gold Noir Abaya',
          category: 'Abayas',
          quantity: 1,
          size: '56',
          color: 'Midnight Black / Gold',
          price: 28500,
          imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
        ),
        OrderItem(
          name: 'Pure Medina Silk Hijab',
          category: 'Hijabs',
          quantity: 1,
          size: 'Standard (180x75cm)',
          color: 'Emerald Silk',
          price: 8500,
          imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
        ),
      ],
      timeline: const [
        OrderTimelineStep(
          title: 'Order Placed',
          subtitle: 'Payment verified successfully via Card',
          date: 'Yesterday, 10:15 AM',
          isCompleted: true,
        ),
        OrderTimelineStep(
          title: 'Custom Sizing & Quality Check',
          subtitle: 'Inspected by Al-Nur Master Tailors',
          date: 'Yesterday, 03:40 PM',
          isCompleted: true,
        ),
        OrderTimelineStep(
          title: 'Dispatched from Hub',
          subtitle: 'En route from Lekki Fulfilment Center',
          date: 'Today, 09:20 AM',
          isCompleted: true,
        ),
        OrderTimelineStep(
          title: 'Out for Delivery',
          subtitle: 'Courier Driver: Ibrahim (+234 803 123 4567)',
          date: 'Today, 01:10 PM',
          isCompleted: true,
          isCurrent: true,
        ),
        OrderTimelineStep(
          title: 'Delivered',
          subtitle: 'Package signed and handed over',
          date: 'Estimated by 4:30 PM',
          isCompleted: false,
        ),
      ],
    ),
    OrderModel(
      id: 'ALN-79104',
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.processing,
      trackingNumber: 'ALN-TRK-7719280',
      deliveryAddress: 'No. 8, Gana Street, Maitama, Abuja FCT',
      estimatedDelivery: 'Oct 25, 2026',
      subtotal: 36000,
      shippingFee: 3000,
      totalAmount: 39000,
      items: const [
        OrderItem(
          name: 'Moroccan Royal Jalabia',
          category: 'Jalabias',
          quantity: 1,
          size: 'L',
          color: 'Royal Emerald / Gold Sfifa',
          price: 36000,
          imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
        ),
      ],
      timeline: const [
        OrderTimelineStep(
          title: 'Order Confirmed',
          subtitle: 'Artisanal Moroccan tailoring scheduled',
          date: 'Oct 20, 02:15 PM',
          isCompleted: true,
        ),
        OrderTimelineStep(
          title: 'Handcrafted Embroidery',
          subtitle: 'Applying intricate Sfifa gold threading',
          date: 'Oct 21, 11:30 AM',
          isCompleted: true,
          isCurrent: true,
        ),
        OrderTimelineStep(
          title: 'Packaging & Blessing',
          subtitle: 'Perfumed with natural Oud & sealed',
          date: 'Pending',
          isCompleted: false,
        ),
        OrderTimelineStep(
          title: 'Courier Dispatch',
          subtitle: 'Waybill generated for Abuja air transit',
          date: 'Pending',
          isCompleted: false,
        ),
      ],
    ),
    OrderModel(
      id: 'ALN-64218',
      orderDate: DateTime.now().subtract(const Duration(days: 12)),
      status: OrderStatus.completed,
      trackingNumber: 'ALN-TRK-6421800',
      deliveryAddress: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos',
      estimatedDelivery: 'Delivered on Oct 14, 2026',
      subtotal: 52000,
      shippingFee: 2500,
      totalAmount: 54500,
      items: const [
        OrderItem(
          name: 'Emirati Minimalist Thobe',
          category: 'Thobes',
          quantity: 2,
          size: '58L',
          color: 'Crisp White',
          price: 26000,
          imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=500&q=80',
        ),
      ],
      timeline: const [
        OrderTimelineStep(
          title: 'Delivered Successfully',
          subtitle: 'Received and confirmed by customer',
          date: 'Oct 14, 02:45 PM',
          isCompleted: true,
        ),
      ],
    ),
    OrderModel(
      id: 'ALN-58190',
      orderDate: DateTime.now().subtract(const Duration(days: 28)),
      status: OrderStatus.completed,
      trackingNumber: 'ALN-TRK-5819022',
      deliveryAddress: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos',
      estimatedDelivery: 'Delivered on Sep 29, 2026',
      subtotal: 38000,
      shippingFee: 2500,
      totalAmount: 40500,
      items: const [
        OrderItem(
          name: 'Pearl Beaded Organza Abaya',
          category: 'Abayas',
          quantity: 1,
          size: '54',
          color: 'Warm Taupe',
          price: 38000,
          imageUrl: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&w=500&q=80',
        ),
      ],
      timeline: const [
        OrderTimelineStep(
          title: 'Delivered Successfully',
          subtitle: 'Received and verified',
          date: 'Sep 29, 01:20 PM',
          isCompleted: true,
        ),
      ],
    ),
    OrderModel(
      id: 'ALN-49012',
      orderDate: DateTime.now().subtract(const Duration(days: 45)),
      status: OrderStatus.cancelled,
      trackingNumber: 'ALN-TRK-4901289',
      deliveryAddress: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos',
      estimatedDelivery: 'Refund completed',
      subtotal: 42000,
      shippingFee: 0,
      totalAmount: 42000,
      items: const [
        OrderItem(
          name: 'Velvet Trim Midnight Abaya',
          category: 'Abayas',
          quantity: 1,
          size: '56',
          color: 'Midnight Blue',
          price: 42000,
          imageUrl: 'https://images.unsplash.com/photo-1617922001439-4a2e6562f328?auto=format&fit=crop&w=500&q=80',
        ),
      ],
      timeline: const [
        OrderTimelineStep(
          title: 'Order Cancelled & Refunded',
          subtitle: '₦42,000 refunded to original card',
          date: 'Sep 10, 04:10 PM',
          isCompleted: true,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> get _activeOrders => _allOrders
      .where((o) => o.status == OrderStatus.inTransit || o.status == OrderStatus.processing)
      .toList();

  List<OrderModel> get _completedOrders =>
      _allOrders.where((o) => o.status == OrderStatus.completed).toList();

  List<OrderModel> get _cancelledOrders =>
      _allOrders.where((o) => o.status == OrderStatus.cancelled).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Active (${_activeOrders.length})'),
            Tab(text: 'Completed (${_completedOrders.length})'),
            Tab(text: 'Cancelled (${_cancelledOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_activeOrders, isCurrentTabActive: true),
          _buildOrdersList(_completedOrders),
          _buildOrdersList(_cancelledOrders),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, {bool isCurrentTabActive = false}) {
    if (orders.isEmpty) {
      return Center(
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
                child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Orders Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your modest clothing orders will appear here once placed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.primaryContainer,
                                child: const Icon(Icons.checkroom, color: AppColors.primary),
                              ),
                            ),
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
                    )),

                const Divider(color: AppColors.border),

                // Order Meta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • Free Scenting',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Total: ',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                          order.status == OrderStatus.completed
                              ? Icons.refresh_rounded
                              : Icons.local_shipping_outlined,
                          size: 16,
                        ),
                        label: Text(
                          order.status == OrderStatus.completed
                              ? 'Buy Again'
                              : 'Track Order',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          if (order.status == OrderStatus.completed) {
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
                          order.status == OrderStatus.completed
                              ? Icons.star_border_rounded
                              : Icons.receipt_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          order.status == OrderStatus.completed
                              ? 'Review Item'
                              : 'View Invoice',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          if (order.status == OrderStatus.completed) {
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live Order Tracking', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('Tracking ID: ${order.trackingNumber}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.estimatedDelivery,
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
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
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Timeline',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
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
                                fontWeight: step.isCurrent ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 13,
                                color: step.isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.date,
                              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: const Text('Call Courier Driver'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to Ibrahim (+234 803 123 4567)...')),
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
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Al-Nur Official Invoice', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('Invoice #: INV-${order.id}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const Divider(height: 28),
            const Text('Itemized Breakdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.name} (${item.size}) x${item.quantity}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            Text('₦${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                      Text('₦${order.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Standard Doorstep Delivery', style: TextStyle(color: AppColors.textSecondary)),
                      Text('₦${order.shippingFee.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Islamic Oud Scenting & Gift Box', style: TextStyle(color: AppColors.textSecondary)),
                      Text('FREE', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download PDF Receipt'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invoice ${order.id} downloaded to your device')),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Rate & Review', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How was the quality and modest fit of your ${order.items.first.name}?',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
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
                  hintText: 'Share fabric texture, drape, and sizing thoughts...',
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
              child: const Text('Later', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jazakallahu Khair! Your review was submitted.'),
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
        content: Text('Added ${order.items.length} items from ${order.id} back to your cart!'),
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
                const SnackBar(content: Text('Connecting to Al-Nur Concierge...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
