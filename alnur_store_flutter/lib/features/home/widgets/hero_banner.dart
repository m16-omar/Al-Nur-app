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
      'tag': 'HAUTE MODESTY',
      'title': 'Luxury Abayas\nfor Every Occasion',
      'subtitle': 'Modest. Stylish. Timeless.',
      'buttonText': 'Shop Now →',
      'imageUrl': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'RAMADAN & EID',
      'title': 'Pure Medina Silk\nHijab Collection',
      'subtitle': 'Breathable. Graceful. Pure.',
      'buttonText': 'Explore →',
      'imageUrl': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=600&q=80',
    },
    {
      'tag': 'ARTISANAL LUXURY',
      'title': 'Royal Moroccan\nJalabias & Kaftans',
      'subtitle': 'Embroidered Festive Elegance.',
      'buttonText': 'View All →',
      'imageUrl': 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=600&q=80',
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
