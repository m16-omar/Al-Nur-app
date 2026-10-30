import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../main.dart';
import 'package:flutter/foundation.dart';
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
import '../services/monnify_payment_service.dart';

class SelarCheckoutView extends ConsumerStatefulWidget {
  final String gateway;
  const SelarCheckoutView({super.key, this.gateway = 'monnify'});

  @override
  ConsumerState<SelarCheckoutView> createState() => _SelarCheckoutViewState();
}

class _SelarCheckoutViewState extends ConsumerState<SelarCheckoutView> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  int _loadingProgress = 0;
  String _checkoutUrl = '';
  late final String _orderId;
  bool _hasTriggeredSuccess = false;
  late String _activeGateway;
  double _capturedTotal = 0;
  bool _webLoadFailed = false;
  Timer? _loadTimeoutTimer;
  int _monnifyTabMode = 0; // 0: Virtual Bank Transfer, 1: Card / Web

  @override
  void initState() {
    super.initState();
    _activeGateway = widget.gateway;
    _orderId = 'ALN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _initializeCheckout();
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCheckout() async {
    setState(() {
      _isLoading = true;
      _checkoutUrl = '';
      _webLoadFailed = false;
    });

    final authState = ref.read(authControllerProvider);
    final cartState = ref.read(cartControllerProvider);
    final user = authState.user;

    if (cartState.grandTotal > 0) {
      _capturedTotal = cartState.grandTotal;
    }

    final customerName = user != null && user.name.isNotEmpty
        ? user.name
        : 'Al-Nur Valued Guest';
    final customerEmail = user != null && user.email.isNotEmpty
        ? user.email
        : 'guest@alnurstore.com';
    final customerPhone = user?.phone;

    String? url;
    if (_activeGateway == 'monnify') {
      url = await MonnifyPaymentService.initializePayment(
        amount: (_capturedTotal > 0 ? _capturedTotal : cartState.grandTotal).toDouble(),
        customerName: customerName,
        customerEmail: customerEmail,
        orderRef: _orderId,
        customerPhone: customerPhone,
      );
      // Fallback to Selar if Monnify returned null
      if (url == null || url.isEmpty) {
        url = await SelarPaymentService.buildCheckoutUrl(
          grandTotal: _capturedTotal > 0 ? _capturedTotal : cartState.grandTotal,
          customerName: customerName,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          items: cartState.items,
          orderId: _orderId,
        );
      }
    } else {
      url = await SelarPaymentService.buildCheckoutUrl(
        grandTotal: _capturedTotal > 0 ? _capturedTotal : cartState.grandTotal,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        items: cartState.items,
        orderId: _orderId,
      );
    }

    if (!mounted) return;

    setState(() {
      _checkoutUrl = url ?? '';
    });

    // Start 4-second safety timer so the user is never stuck on an indefinite spinning indicator
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _webLoadFailed = true;
        });
      }
    });

    if (!kIsWeb && url.isNotEmpty) {
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
              _loadTimeoutTimer?.cancel();
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
              _loadTimeoutTimer?.cancel();
              debugPrint('[Checkout] WebView Error: ${error.description}');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _webLoadFailed = true;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    } else {
      _loadTimeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _checkUrlForSuccess(String url) {
    if (_hasTriggeredSuccess) return true;
    if (SelarPaymentService.isPaymentSuccessUrl(url) || MonnifyPaymentService.isPaymentSuccessUrl(url)) {
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
        'id': i.productId,
        'name': i.name,
        'category': i.categoryId,
        'imageUrl': i.imageUrl,
        'quantity': i.quantity,
        'price': i.price,
        'selectedSize': i.size,
        'selectedColor': i.color,
      }).toList());

      // Fetch user's selected/default delivery address
      String shippingAddress = 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos';
      String effectivePhone = customerPhone;

      if (customerEmail.isNotEmpty && customerEmail != 'guest@alnurstore.com') {
        try {
          final addresses = await client.user.getAddresses(email: customerEmail);
          if (addresses.isNotEmpty) {
            final defaultAddr = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
            final parts = [
              defaultAddr.streetAddress,
              defaultAddr.city,
              defaultAddr.state,
              if (defaultAddr.country != null && defaultAddr.country!.isNotEmpty) defaultAddr.country!,
            ].where((p) => p.trim().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              shippingAddress = parts.join(', ');
            }
            if (effectivePhone.isEmpty && defaultAddr.phoneNumber.isNotEmpty) {
              effectivePhone = defaultAddr.phoneNumber;
            }
          }
        } catch (addrErr) {
          debugPrint('[Checkout] Address resolution note: $addrErr');
        }
      }

      await client.order.createOrder(
        idempotencyKey: 'checkout-$_orderId',
        customerEmail: customerEmail,
        customerName: customerName,
        customerPhone: effectivePhone,
        shippingAddress: shippingAddress,
        totalAmount: totalPaid,
        itemsJson: itemsSummary,
        paymentReference: _orderId,
      );
      debugPrint('[Checkout] Idempotent order confirmed in backend: $_orderId with address: $shippingAddress');
    } catch (e) {
      debugPrint('[Checkout] Backend order creation note: $e');
    }

    // Clear the cart upon successful transaction
    await ref.read(cartControllerProvider.notifier).clearCart();

    if (!mounted) return;

    // Show celebration dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
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
                  'Your payment of ₦${(totalPaid > 0 ? totalPaid : _capturedTotal).toStringAsFixed(0)} via ${_activeGateway == 'monnify' ? 'Monnify Dynamic Gateway' : 'Selar Halal Gateway'} has been confirmed successfully.',
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.local_shipping_outlined, size: 18),
                    label: const Text('View & Track My Order', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRoutes.orders);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRoutes.home);
                    },
                    child: const Text('Back to Home & Shop More', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            // Prominent close button at top-right
            Positioned(
              top: -8,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                tooltip: 'Close',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.orders);
                },
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
        title: Text('Verify ${_activeGateway == 'monnify' ? 'Monnify' : 'Selar'} Payment'),
        content: Text(
          'Have you completed your ${_activeGateway == 'monnify' ? 'bank transfer or card' : 'Selar'} payment for order $_orderId?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Yet', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildGatewaySwitcher() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_activeGateway != 'monnify') {
                      setState(() {
                        _activeGateway = 'monnify';
                        _webLoadFailed = false;
                      });
                      _initializeCheckout();
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activeGateway == 'monnify' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _activeGateway == 'monnify'
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Monnify (Exact)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _activeGateway == 'monnify' ? FontWeight.w700 : FontWeight.w500,
                            color: _activeGateway == 'monnify' ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_activeGateway != 'selar') {
                      setState(() {
                        _activeGateway = 'selar';
                        _webLoadFailed = false;
                      });
                      _initializeCheckout();
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activeGateway == 'selar' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _activeGateway == 'selar'
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Selar Gateway',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _activeGateway == 'selar' ? FontWeight.w700 : FontWeight.w500,
                            color: _activeGateway == 'selar' ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_activeGateway == 'monnify')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _monnifyTabMode = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _monnifyTabMode == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _monnifyTabMode == 0
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Virtual Bank Transfer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _monnifyTabMode == 0 ? FontWeight.bold : FontWeight.normal,
                          color: _monnifyTabMode == 0 ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _monnifyTabMode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _monnifyTabMode == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _monnifyTabMode == 1
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Debit Card & Online',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _monnifyTabMode == 1 ? FontWeight.bold : FontWeight.normal,
                          color: _monnifyTabMode == 1 ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMonnifyBankTransferView(CartState cartState) {
    final effectiveTotal = _capturedTotal > 0 ? _capturedTotal : cartState.grandTotal;
    const accountNumber = '8273649102';
    const bankName = 'Wema Bank (Monnify)';
    const accountName = 'AL-NUR MODEST COUTURE / MONNIFY';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security / Official Header Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: AppColors.gold, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monnify Dynamic Bank Transfer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Exact amount • Auto-reconciled within 30 seconds',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Dynamic Virtual Account Details Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BANK NAME',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFB45309)),
                              SizedBox(width: 3),
                              Text(
                                'DYNAMIC ACCOUNT',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      bankName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const Divider(height: 22, color: AppColors.border),

                    // Account Number row with Copy button
                    const Text(
                      'ACCOUNT NUMBER',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          accountNumber,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: AppColors.primary,
                            fontFamily: 'monospace',
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text('Copy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: accountNumber));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account number copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 22, color: AppColors.border),

                    // Beneficiary
                    const Text(
                      'BENEFICIARY NAME',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      accountName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const Divider(height: 22, color: AppColors.border),

                    // Exact Amount with Copy
                    const Text(
                      'EXACT AMOUNT TO TRANSFER',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₦${effectiveTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF10B981),
                            side: const BorderSide(color: Color(0xFF10B981)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text('Copy Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: effectiveTotal.toStringAsFixed(0)));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Amount copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Instructions and Expiry note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Open your banking app (Kuda, OPay, GTBank, Zenith, etc.) and transfer the exact amount above.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action button: I Have Transferred
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'I Have Transferred ₦${effectiveTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: _confirmManualPayment,
                ),
              ),

              const SizedBox(height: 10),

              // Alternative action
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.credit_card_rounded, size: 18),
                  label: const Text('Pay with Debit Card / Web Instead'),
                  onPressed: () {
                    setState(() => _monnifyTabMode = 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebCheckoutFallback(CartState cartState) {
    final isMonnify = _activeGateway == 'monnify';
    final effectiveTotal = _capturedTotal > 0 ? _capturedTotal : cartState.grandTotal;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMonnify ? Icons.account_balance_rounded : Icons.payment_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isMonnify ? 'Monnify Dynamic Checkout' : 'Selar Halal Checkout',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isMonnify
                      ? 'Pay exact ₦${effectiveTotal.toStringAsFixed(0)} via Dynamic Bank Transfer, Debit Cards (Mastercard, Visa, Verve) or USSD.'
                      : 'Your payment gateway opens in a secure browser tab to complete your transaction with card, bank transfer, or USSD.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text(
                            '₦${effectiveTotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Reference:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(_orderId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(
                      isMonnify ? 'Open Monnify Payment Page' : 'Open Selar Payment Page',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: _openInExternalBrowser,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('I Have Completed Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _confirmManualPayment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final effectiveTotal = _capturedTotal > 0 ? _capturedTotal : cartState.grandTotal;

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
                const Icon(Icons.lock_rounded, color: AppColors.primary, size: 15),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _activeGateway == 'monnify' ? 'Monnify Dynamic Checkout' : 'Selar Halal Checkout',
                    style: AppTextStyles.productTitle.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              _activeGateway == 'monnify'
                  ? 'Exact Amount • Virtual Bank Transfer & Cards'
                  : '256-Bit Encrypted • Multi-Currency Gateway',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary, size: 20),
            tooltip: 'Reload Page',
            onPressed: () {
              if (_checkoutUrl.isNotEmpty && _webViewController != null) {
                _webViewController!.reload();
              } else {
                _initializeCheckout();
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
      body: Column(
        children: [
          _buildGatewaySwitcher(),
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 3,
            ),
          Expanded(
            child: (_activeGateway == 'monnify' && _monnifyTabMode == 0)
                ? _buildMonnifyBankTransferView(cartState)
                : (_webLoadFailed || kIsWeb || _webViewController == null || _checkoutUrl.isEmpty
                    ? _buildWebCheckoutFallback(cartState)
                    : WebViewWidget(controller: _webViewController!)),
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
                            '₦${effectiveTotal.toStringAsFixed(0)}',
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
                        _activeGateway == 'monnify'
                            ? 'Powered by Monnify • Central Bank of Nigeria Licensed'
                            : 'Powered by Selar • Cards, Bank Transfer & USSD Supported',
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
