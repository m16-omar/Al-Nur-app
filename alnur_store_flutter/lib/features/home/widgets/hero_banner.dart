import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HeroBanner extends StatefulWidget {
  final VoidCallback? onShopNowTap;

  const HeroBanner({
    super.key,
    this.onShopNowTap,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _banners = [
    {
      'tag': 'ROYAL PERFUMERY',
      'title': 'Arabian Oud &\nLuxury Fragrances',
      'subtitle': 'Oud. Amber. Long-Lasting.',
      'buttonText': 'Explore Scents →',
      'imageUrl': 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'BRIDAL & NIKAH',
      'title': '18K Gold Plated\nWedding Rings',
      'subtitle': 'Couple Bands. Eternal Love.',
      'buttonText': 'View Bands →',
      'imageUrl': 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'FINE TIMEPIECES',
      'title': 'Diamond-Bezel\nLuxury Wristwatches',
      'subtitle': 'Emerald Green. Rose Gold.',
      'buttonText': 'Discover Watches →',
      'imageUrl': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'NIGERIAN LUXURY',
      'title': 'Zainab Bridal Chokers\n& Statement Rings',
      'subtitle': 'Austrian Crystals. Non-Tarnish.',
      'buttonText': 'Shop Jewelry →',
      'imageUrl': 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 195,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF3F2D1E), Color(0xFF8C7150), Color(0xFFC4AB89)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F2D1E).withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Row(
                    children: [
                      // Left Content
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(banner['tag']!, style: AppTextStyles.heroBadge),
                                  const SizedBox(height: 4),
                                  Text(banner['title']!, style: AppTextStyles.heroTitle),
                                  const SizedBox(height: 3),
                                  Text(banner['subtitle']!, style: AppTextStyles.heroSubtitle),
                                ],
                              ),

                              const Spacer(),

                              // Pill Button
                              GestureDetector(
                                onTap: widget.onShopNowTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(banner['buttonText']!, style: AppTextStyles.heroButton),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Page Indicator Dots with generous spacing
                              Row(
                                children: List.generate(
                                  _banners.length,
                                  (dotIndex) => GestureDetector(
                                    onTap: () => _pageController.animateToPage(
                                      dotIndex,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.only(right: 6),
                                      width: _currentPage == dotIndex ? 18 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentPage == dotIndex
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right Image with Architectural Islamic Arch Framing
                      Expanded(
                        flex: 4,
                        child: CustomPaint(
                          foregroundPainter: const ArchImageBorderPainter(
                            radius: 68,
                            color: AppColors.gold,
                            strokeWidth: 2.0,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(68),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  banner['imageUrl']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackModel(),
                                ),
                                // Gradient blend on the left curve edge
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF3F2D1E).withValues(alpha: 0.35),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildFallbackModel() {
    return Container(
      color: const Color(0xFF6B533E),
      child: const Center(
        child: Icon(Icons.person_outline_rounded, color: Colors.white70, size: 50),
      ),
    );
  }
}

/// Paints a luxury gold Islamic arch stroke directly bordering and framing the product image.
class ArchImageBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;

  const ArchImageBorderPainter({
    this.radius = 68,
    this.color = AppColors.gold,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final halfStroke = strokeWidth / 2;
    final path = Path();
    path.moveTo(halfStroke, size.height);
    path.lineTo(halfStroke, radius);
    path.arcToPoint(
      Offset(radius, halfStroke),
      radius: Radius.circular(radius - halfStroke),
      clockwise: true,
    );
    path.lineTo(size.width, halfStroke);

    // Subtle luminous soft glow behind the arch
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glowPaint);

    // Primary luxury gold stroke
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ArchImageBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
