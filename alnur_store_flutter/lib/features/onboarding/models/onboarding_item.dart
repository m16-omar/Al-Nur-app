import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String highlightWord;
  final String description;
  final String categoryTag;
  final String badgeText;
  final String imagePath;
  final String fallbackEmoji;
  final String imageUrl;
  final String topBadge;
  final List<String> tags;
  final String? interactiveSnippet;
  final IconData icon;

  const OnboardingItem({
    required this.title,
    required this.highlightWord,
    required this.description,
    required this.categoryTag,
    required this.badgeText,
    required this.imagePath,
    required this.fallbackEmoji,
    required this.imageUrl,
    required this.topBadge,
    required this.tags,
    this.interactiveSnippet,
    required this.icon,
  });

  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Modest Luxury For Every',
      highlightWord: 'Occasion',
      description:
          'Explore handpicked premium abayas, flowing kaftans, and fine hijabs tailored with graceful modest silhouettes and artisanal fabrics.',
      categoryTag: 'CURATED COLLECTION',
      badgeText: 'Haute Modesty 2026',
      imagePath: 'assets/images/onboarding/onboarding_1.png',
      fallbackEmoji: '✨',
      imageUrl:
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=900&q=85',
      topBadge: '✦ AL-NUR ATELIER • 2026',
      tags: ['Dubai Abayas', 'Pure Medina Silk', 'Moroccan Kaftans'],
      interactiveSnippet: 'Tailored fit & modest grace in every stitch',
      icon: Icons.dry_cleaning_rounded,
    ),
    OnboardingItem(
      title: 'Meet Your Personal',
      highlightWord: 'AI Stylist',
      description:
          'Ask questions, match complementary hijab color palettes, and receive instant modest styling recommendations curated specifically for you.',
      categoryTag: 'SMART FASHION AI',
      badgeText: 'Powered by Gemini AI',
      imagePath: 'assets/images/onboarding/onboarding_2.png',
      fallbackEmoji: '🧕',
      imageUrl:
          'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=900&q=85',
      topBadge: '✨ GEMINI AI • MODEST STYLIST',
      tags: ['Palette Matching', 'Occasion Advisory', 'Size Guidance'],
      interactiveSnippet: '“Suggest a sage green abaya with champagne hijab”',
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingItem(
      title: 'Effortless Shopping &',
      highlightWord: 'Fast Delivery',
      description:
          'Enjoy smooth checkout, instant local currency pricing in Naira (₦), and expedited doorstep delivery across Nigeria with 100% Halal sourcing.',
      categoryTag: 'SEAMLESS SERVICE',
      badgeText: 'Expedited & Secure',
      imagePath: 'assets/images/onboarding/onboarding_3.png',
      fallbackEmoji: '🛍️',
      imageUrl:
          'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=900&q=85',
      topBadge: '⚡ WHITE GLOVE DISPATCH',
      tags: ['24-48h Delivery', '₦ Naira Local Pay', '100% Halal Certified'],
      interactiveSnippet: 'Doorstep delivery across Lagos, Abuja & nationwide',
      icon: Icons.local_shipping_rounded,
    ),
  ];
}
