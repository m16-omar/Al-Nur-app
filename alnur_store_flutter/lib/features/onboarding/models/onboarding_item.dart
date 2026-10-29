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
      title: 'Curated Luxury For Every',
      highlightWord: 'Celebration',
      description:
          'Discover exquisite wedding rings, royal Arabian oud, diamond-bezel wristwatches, and fine jewelry handpicked for Nigerian elegance.',
      categoryTag: 'CURATED COLLECTION',
      badgeText: 'Nigerian Luxury 2026',
      imagePath: 'assets/images/onboarding/onboarding_1.png',
      fallbackEmoji: '✨',
      imageUrl:
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=900&q=85',
      topBadge: '✦ AL-NUR JEWELS & SCENTS',
      tags: ['Wedding Rings', 'Royal Arabian Oud', 'Luxury Timepieces'],
      interactiveSnippet: 'Non-tarnish 18K gold and authentic royal fragrances',
      icon: Icons.diamond_rounded,
    ),
    OnboardingItem(
      title: 'Meet Your Personal',
      highlightWord: 'AI Stylist',
      description:
          'Receive instant jewelry pairing, wedding ring sizing advisory, and long-lasting Arabian fragrance layering recommendations tailored for your events.',
      categoryTag: 'SMART LUXURY AI',
      badgeText: 'Powered by Gemini AI',
      imagePath: 'assets/images/onboarding/onboarding_2.png',
      fallbackEmoji: '💎',
      imageUrl:
          'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=900&q=85',
      topBadge: '✨ GEMINI AI • LUXURY CONCIERGE',
      tags: ['Scent Layering', 'Bridal Advisory', 'Ring Stacking'],
      interactiveSnippet: '“Suggest matching 18k couple bands with royal oud”',
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingItem(
      title: 'Effortless Shopping &',
      highlightWord: 'Fast Delivery',
      description:
          'Enjoy smooth checkout, instant local currency pricing in Naira (₦), and expedited doorstep delivery across Lagos, Abuja, Kano & nationwide with verified non-tarnish quality.',
      categoryTag: 'SEAMLESS SERVICE',
      badgeText: 'Expedited & Secure',
      imagePath: 'assets/images/onboarding/onboarding_3.png',
      fallbackEmoji: '🛍️',
      imageUrl:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=900&q=85',
      topBadge: '⚡ WHITE GLOVE DISPATCH',
      tags: ['24-48h Delivery', '₦ Naira Local Pay', 'Verified Quality Guarantee'],
      interactiveSnippet: 'Doorstep delivery across Lagos, Abuja & nationwide',
      icon: Icons.local_shipping_rounded,
    ),
  ];
}
