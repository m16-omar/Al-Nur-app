import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';

class CartView extends ConsumerStatefulWidget {
  final bool isModal;
  final bool isEmbeddedTab;
  final VoidCallback? onClose;
  final VoidCallback? onBackToHome;

  const CartView({
    super.key,
    this.isModal = false,
    this.isEmbeddedTab = false,
    this.onClose,
    this.onBackToHome,
  });

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  String _formatNaira(num amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  void _handleCheckout(CartState cartState) {
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your shopping bag is empty. Add modest garments to checkout.')),
      );
      return;
    }

    final authState = ref.read(authControllerProvider);
    final isGuest = authState.user == null || authState.isGuest || !authState.isAuthenticated;

    if (isGuest) {
      // Restriction: Guest users must sign in to proceed with checkout
      _showGuestRestrictionDialog(cartState);
    } else {
      // Authenticated member: proceed with Selar Payment Gateway
      context.push(AppRoutes.selarCheckout);
    }
  }

  void _showGuestRestrictionDialog(CartState cartState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: AppColors.goldDark,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign In Required to Checkout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                children: [
                  const TextSpan(text: 'Assalamu Alaikum! Your items ('),
                  TextSpan(
                    text: '${cartState.totalCount} items • ${_formatNaira(cartState.grandTotal)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const TextSpan(
                    text:
                        ') are securely saved in your shopping bag. Please sign in to verify your delivery address and finalize your halal order.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Sign In / Create Account',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (widget.isModal && widget.onClose != null) {
                    widget.onClose!();
                  }
                  context.push(AppRoutes.login);
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Continue Browsing as Guest',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cartController = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                onPressed: widget.onClose ?? () => Navigator.pop(context),
              )
            : widget.isEmbeddedTab
                ? (widget.onBackToHome != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                        onPressed: widget.onBackToHome,
                      )
                    : null)
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                    onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
                  ),
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Modest Shopping Bag',
              style: AppTextStyles.productTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: () => cartController.clearCart(),
              child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // Cart Item List
                      ...cartState.items.map(
                        (item) => _buildCartItemCard(item, cartController),
                      ),

                      const SizedBox(height: 16),

                      // Promo Code Voucher Card
                      _buildPromoSection(cartState, cartController),

                      const SizedBox(height: 16),

                      // Order Bill Breakdown
                      _buildBillBreakdown(cartState),
                    ],
                  ),
                ),

                // Bottom Checkout Bar
                _buildBottomCheckoutBar(cartState),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Modest Bag is Empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover our curated Abayas, Silk Hijabs, Moroccan Jalabias, and tailored Thobes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.storefront_outlined, size: 18, color: Colors.white),
                label: const Text(
                  'Explore Modest Collections',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                onPressed: () {
                  if (widget.isModal && widget.onClose != null) {
                    widget.onClose!();
                  } else if (widget.isEmbeddedTab && widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItemModel item, CartController cartController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: AppColors.surfaceMuted,
                child: const Icon(Icons.dry_cleaning_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Size ${item.size}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    if (item.color.isNotEmpty && item.color != 'Default') ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.color,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatNaira(item.price),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Quantity Stepper
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.remove_rounded, size: 16, color: AppColors.textPrimary),
                  onPressed: () => cartController.updateQuantity(item.id, -1),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  onPressed: () => cartController.updateQuantity(item.id, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(CartState cartState, CartController cartController) {
    final hasPromo = cartState.appliedPromoCode != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasPromo ? const Color(0xFFFBF4E6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPromo ? AppColors.gold.withValues(alpha: 0.6) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPromo ? Icons.check_circle_rounded : Icons.confirmation_number_outlined,
                color: hasPromo ? AppColors.goldDark : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasPromo
                      ? 'Promo Code: ${cartState.appliedPromoCode} (15% OFF)'
                      : 'Modesty Voucher / Promo Code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasPromo ? AppColors.goldDark : AppColors.textPrimary,
                  ),
                ),
              ),
              if (hasPromo)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => cartController.togglePromoCode(''),
                  child: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (!hasPromo) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter code e.g. ALNUR15',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final code = _promoController.text.trim();
                    if (code.isNotEmpty) {
                      cartController.togglePromoCode(code);
                      _promoController.clear();
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillBreakdown(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', _formatNaira(cartState.subtotal)),
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              'Modesty Voucher (15%)',
              '-${_formatNaira(cartState.discountAmount)}',
              isGreen: true,
            ),
          ],
          const SizedBox(height: 8),
          _buildRow('Halal Express Delivery', _formatNaira(cartState.shippingFee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _buildRow('Grand Total', _formatNaira(cartState.grandTotal), isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isGreen
                ? const Color(0xFF10B981)
                : (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(CartState cartState) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, widget.isEmbeddedTab ? 104 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !widget.isEmbeddedTab,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => _handleCheckout(cartState),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Pay with Selar • ${_formatNaira(cartState.grandTotal)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
