import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Animated3dLogo extends StatefulWidget {
  final double size;

  const Animated3dLogo({
    super.key,
    this.size = 140,
  });

  @override
  State<Animated3dLogo> createState() => _Animated3dLogoState();
}

class _Animated3dLogoState extends State<Animated3dLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle floating yaw and pitch rotations to create 3D depth
        final angleY = math.sin(_controller.value * 2 * math.pi) * 0.18;
        final angleX = math.cos(_controller.value * 2 * math.pi) * 0.12;
        final floatOffset = math.sin(_controller.value * 2 * math.pi) * 8;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective projection
              ..rotateY(angleY)
              ..rotateX(angleX),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Deep ambient glow
                Container(
                  width: widget.size * 1.3,
                  height: widget.size * 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentMint.withValues(alpha: 0.25),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        blurRadius: 60,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // 3D Shadow layer (extruded depth back layer)
                Transform.translate(
                  offset: const Offset(4, 8),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size * 0.28),
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),

                // Main 3D Card Surface
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size * 0.28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF23654F),
                        Color(0xFF133C2F),
                        Color(0xFF0D281E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.6),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.size * 0.28),
                    child: Stack(
                      children: [
                        // Specular lighting reflection diagonal
                        Positioned(
                          top: -widget.size * 0.5,
                          left: -widget.size * 0.5,
                          child: Container(
                            width: widget.size * 2,
                            height: widget.size * 0.8,
                            transform: Matrix4.rotationZ(-math.pi / 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Center Islamic Dome and Crescent Emblem
                        Center(
                          child: CustomPaint(
                            size: Size(widget.size * 0.55, widget.size * 0.55),
                            painter: Logo3dPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Logo3dPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dome shadow layer
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final shadowPath = Path();
    shadowPath.moveTo(w * 0.18, h * 0.92);
    shadowPath.lineTo(w * 0.18, h * 0.55);
    shadowPath.cubicTo(w * 0.18, h * 0.25, w * 0.46, h * 0.12, w * 0.52, h * 0.07);
    shadowPath.cubicTo(w * 0.58, h * 0.12, w * 0.86, h * 0.25, w * 0.86, h * 0.55);
    shadowPath.lineTo(w * 0.86, h * 0.92);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Main Dome Arch in Gold gradient
    final domePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFC7A168), Color(0xFF8F6E3B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.15, h * 0.9);
    path.lineTo(w * 0.15, h * 0.52);
    path.cubicTo(w * 0.15, h * 0.22, w * 0.45, h * 0.1, w * 0.5, h * 0.04);
    path.cubicTo(w * 0.55, h * 0.1, w * 0.85, h * 0.22, w * 0.85, h * 0.52);
    path.lineTo(w * 0.85, h * 0.9);
    path.lineTo(w * 0.65, h * 0.9);
    path.lineTo(w * 0.65, h * 0.62);
    path.cubicTo(w * 0.65, h * 0.46, w * 0.35, h * 0.46, w * 0.35, h * 0.62);
    path.lineTo(w * 0.35, h * 0.9);
    path.close();

    canvas.drawPath(path, domePaint);

    // Inner arch cutout in rich emerald
    final innerPaint = Paint()
      ..color = const Color(0xFF133C2F)
      ..style = PaintingStyle.fill;

    final innerPath = Path();
    innerPath.moveTo(w * 0.37, h * 0.9);
    innerPath.lineTo(w * 0.37, h * 0.64);
    innerPath.cubicTo(w * 0.37, h * 0.5, w * 0.63, h * 0.5, w * 0.63, h * 0.64);
    innerPath.lineTo(w * 0.63, h * 0.9);
    innerPath.close();
    canvas.drawPath(innerPath, innerPaint);

    // Crescent Moon at the Apex
    final moonCenter = Offset(w * 0.5, h * 0.05);
    final moonOuterPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(moonCenter, 4.0, moonOuterPaint);

    final moonCutoutPaint = Paint()
      ..color = const Color(0xFF133C2F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.52, h * 0.04), 3.2, moonCutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
