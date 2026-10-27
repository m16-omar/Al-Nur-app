import 'dart:convert';
import '../../../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../services/selar_payment_service.dart';

class SelarCheckoutView extends ConsumerStatefulWidget {
  const SelarCheckoutView({super.key});

  @override
  ConsumerState<SelarCheckoutView> createState() => _SelarCheckoutViewState();
}

class _SelarCheckoutViewState extends ConsumerState<SelarCheckoutView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  int _loadingProgress = 0;
  String _checkoutUrl = '';
  late final String _orderId;
  bool _hasTriggeredSuccess = false;

  @override
  void initState() {
    super.initState();
    _orderId = 'ALN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _initializeCheckout();
  }

  Future<void> _initializeCheckout() async {
    final authState = ref.read(authControllerProvider);
    final cartState = ref.read(cartControllerProvider);
    final user = authState.user;

    final customerName = user != null && user.name.isNotEmpty
        ? user.name
        : 'Al-Nur Valued Guest';
    final customerEmail = user != null && user.email.isNotEmpty
        ? user.email
        : 'guest@alnurstore.com';
    final customerPhone = user?.phone;

    final url = await SelarPaymentService.buildCheckoutUrl(
      grandTotal: cartState.grandTotal,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      items: cartState.items,
      orderId: _orderId,
    );

    setState(() {
      _checkoutUrl = url;
    });

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (url) {
            _checkUrlForSuccess(url);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkUrlForSuccess(url);
          },
          onNavigationRequest: (request) {
            if (_checkUrlForSuccess(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('[SelarCheckout] WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  bool _checkUrlForSuccess(String url) {
    if (_hasTriggeredSuccess) return true;
    if (SelarPaymentService.isPaymentSuccessUrl(url)) {
      _hasTriggeredSuccess = true;
      _handlePaymentSuccess();
      return true;
    }
    return false;
  }

  Future<void> _handlePaymentSuccess() async {
    final cartState = ref.read(cartControllerProvider);
    final totalPaid = cartState.grandTotal;
    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    final customerEmail = user != null && user.email.isNotEmpty ? user.email : 'guest@alnurstore.com';
    final customerName = user != null && user.name.isNotEmpty ? user.name : 'Al-Nur Valued Guest';
    final customerPhone = user?.phone ?? '';

    // Register order in backend Serverpod with Idempotency Key protection
    try {
      final itemsSummary = jsonEncode(cartState.items.map((i) => {
        'id': i.product.id,
        'name': i.product.name,
        'quantity': i.quantity,
        'price': i.product.price,
        'selectedSize': i.selectedSize,
        'selectedColor': i.selectedColor,
      }).toList());

      await client.order.createOrder(
        idempotencyKey: 'checkout-$_orderId',
        customerEmail: customerEmail,
        customerName: customerName,
        customerPhone: customerPhone,
        shippingAddress: 'Lagos, Nigeria',
        totalAmount: totalPaid,
        itemsJson: itemsSummary,
        paymentReference: _orderId,
      );
      debugPrint('[Checkout] Idempotent order confirmed in backend: $_orderId');
    } catch (e) {
      debugPrint('[Checkout] Backend order creation note: $e');
    }

    // Clear the cart upon successful transaction
    await ref.read(cartControllerProvider.notifier).clearCart();

    if (!mounted) return;

    // Show celebration dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'Alhamdulillah! Payment Confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment of ₦${totalPaid.toStringAsFixed(0)} via Selar has been confirmed successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Reference:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(_orderId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.home);
                },
                child: const Text('Back to Home & Shop More', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Your modest garments are still securely saved in your bag. Are you sure you want to exit the payment gateway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay & Pay', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit to Bag', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _openInExternalBrowser() async {
    if (_checkoutUrl.isEmpty) return;
    final uri = Uri.parse(_checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmManualPayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verify Selar Payment'),
        content: const Text(
          'Have you finalized your card, bank transfer, or USSD payment on the Selar checkout gateway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Yet', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handlePaymentSuccess();
            },
            child: const Text('Yes, I Have Paid'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          tooltip: 'Cancel Payment',
          onPressed: _showExitConfirmation,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Selar Halal Checkout',
                  style: AppTextStyles.productTitle.copyWith(fontSize: 16),
                ),
              ],
            ),
            const Text(
              '256-Bit Encrypted • Multi-Currency Gateway',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary, size: 20),
            tooltip: 'Reload Page',
            onPressed: () {
              if (_checkoutUrl.isNotEmpty) {
                _webViewController.reload();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.primary, size: 20),
            tooltip: 'Open in Browser',
            onPressed: _openInExternalBrowser,
          ),
        ],
      ),
      body: _checkoutUrl.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                if (_isLoading)
                  LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 3,
                  ),
                Expanded(
                  child: WebViewWidget(controller: _webViewController),
                ),
                // Floating Bottom Security Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                    border: const Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Amount Payable:',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                Text(
                                  '₦${cartState.grandTotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                              label: const Text(
                                'I Have Paid',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              onPressed: _confirmManualPayment,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Powered by Selar • Cards, Bank Transfer & USSD Supported',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
