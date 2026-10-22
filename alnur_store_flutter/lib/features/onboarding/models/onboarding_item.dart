class OnboardingItem {
  final String title;
  final String highlightWord;
  final String description;
  final String categoryTag;
  final String badgeText;
  final String imagePath;
  final String fallbackEmoji;

  const OnboardingItem({
    required this.title,
    required this.highlightWord,
    required this.description,
    required this.categoryTag,
    required this.badgeText,
    required this.imagePath,
    required this.fallbackEmoji,
  });

  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Modest Luxury For Every',
      highlightWord: 'Occasion',
      description:
          'Explore handpicked premium abayas, flowing kaftans, and fine hijabs tailored with graceful modest silhouettes.',
      categoryTag: 'CURATED COLLECTION',
      badgeText: 'Haute Modesty 2026',
      imagePath: 'assets/images/onboarding/onboarding_1.png',
      fallbackEmoji: '✨',
    ),
    OnboardingItem(
      title: 'Meet Your Personal',
      highlightWord: 'AI Stylist',
      description:
          'Ask questions, match complementary color palettes, and get instant modest styling recommendations curated for you.',
      categoryTag: 'SMART FASHION AI',
      badgeText: 'Powered by Gemini AI',
      imagePath: 'assets/images/onboarding/onboarding_2.png',
      fallbackEmoji: '🧕',
    ),
    OnboardingItem(
      title: 'Effortless Shopping &',
      highlightWord: 'Fast Delivery',
      description:
          'Enjoy smooth checkout, instant local currency pricing in Naira (₦), and expedited doorstep delivery across Nigeria.',
      categoryTag: 'SEAMLESS SERVICE',
      badgeText: 'Expedited & Secure',
      imagePath: 'assets/images/onboarding/onboarding_3.png',
      fallbackEmoji: '🛍️',
    ),
  ];
}
