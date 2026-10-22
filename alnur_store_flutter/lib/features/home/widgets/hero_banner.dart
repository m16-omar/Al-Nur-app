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
      'tag': 'NEW ARRIVALS',
      'title': 'Elegant Abayas\nfor Every Occasion',
      'subtitle': 'Modest. Stylish. Timeless.',
      'buttonText': 'Shop Now →',
      'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'RAMADAN SPECIAL',
      'title': 'Silk Chiffon\nHijab Collection',
      'subtitle': 'Breathable. Graceful. Pure.',
      'buttonText': 'Explore →',
      'imageUrl': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'TRENDING NOW',
      'title': 'Modest Maxi\nDresses & Robes',
      'subtitle': 'Designed for Modern Elegance.',
      'buttonText': 'View All →',
      'imageUrl': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
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
        height: 180,
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
          child: Stack(
            children: [
              // Architectural Arch Background Decoration
              Positioned(
                right: -30,
                top: -20,
                bottom: -20,
                width: 200,
                child: CustomPaint(
                  painter: ArchBackgroundPainter(),
                ),
              ),

              // PageView Content
              PageView.builder(
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
                          padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            ],
                          ),
                        ),
                      ),

                      // Right Image
                      Expanded(
                        flex: 4,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                banner['imageUrl']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackModel(),
                              ),
                            ),
                            // Gradient blend
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3F2D1E).withValues(alpha: 0.7),
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Page Indicator Dots
              Positioned(
                bottom: 12,
                left: 18,
                child: Row(
                  children: List.generate(
                    _banners.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: _currentPage == index ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _currentPage == index
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

class ArchBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(80),
      topRight: const Radius.circular(80),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
