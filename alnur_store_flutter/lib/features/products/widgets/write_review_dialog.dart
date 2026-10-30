import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/name_formatter.dart';
import '../models/product_review.dart';
import '../repositories/review_repository.dart';

class WriteReviewDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final String? initialUserName;
  final ValueChanged<ProductReview>? onReviewSubmitted;

  const WriteReviewDialog({
    super.key,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.initialUserName,
    this.onReviewSubmitted,
  });

  /// Static helper to display the review dialog responsively on both Web and Mobile.
  static Future<ProductReview?> show(
    BuildContext context, {
    required String productId,
    required String productName,
    String? productImageUrl,
    String? initialUserName,
    ValueChanged<ProductReview>? onReviewSubmitted,
  }) {
    return showDialog<ProductReview>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: WriteReviewDialog(
            productId: productId,
            productName: productName,
            productImageUrl: productImageUrl,
            initialUserName: initialUserName,
            onReviewSubmitted: onReviewSubmitted,
          ),
        ),
      ),
    );
  }

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 5.0;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};

  final List<String> _availableTags = const [
    '👑 Authentic Sillage',
    '💍 18K Non-Tarnish',
    '🎁 Regal Gift Packaging',
    '💎 Precision Craftsmanship',
    '✨ True to Size',
    '⚡ Express Doorstep Delivery',
    '🌿 100% Halal Certified',
  ];

  @override
  void initState() {
    super.initState();
    final cleanInitial = NameFormatter.formatFirstName(widget.initialUserName, fallback: '');
    _nameController = TextEditingController(text: cleanInitial);
    _selectedTags.add('🎁 Regal Gift Packaging');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5.0) return '⭐⭐⭐⭐⭐ Exceptional Luxury • Highly Recommended';
    if (rating >= 4.0) return '⭐⭐⭐⭐ Very Good • Satisfied with Purchase';
    if (rating >= 3.0) return '⭐⭐⭐ Average • Met Expectations';
    if (rating >= 2.0) return '⭐⭐ Fair • Needs Improvement';
    return '⭐ Disappointed';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Verified Patron';
      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Verified Modest Fashion Review';
      final comment = _commentController.text.trim();

      final review = await ReviewRepository.addReview(
        productId: widget.productId,
        userName: name,
        rating: _rating,
        title: title,
        comment: comment,
        tags: _selectedTags.toList(),
      );

      if (!mounted) return;

      widget.onReviewSubmitted?.call(review);
      Navigator.of(context).pop(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jazakallahu Khair! Your review has been published.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to submit review: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.rate_review_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Rate & Review Item',
                                style: AppTextStyles.productTitle.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.productName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                      tooltip: 'Close Form',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const Divider(height: 24, color: AppColors.border),

                // Interactive 5-Star Rating Selector
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Tap stars to rate your satisfaction:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starValue = (index + 1).toDouble();
                          final isFilled = starValue <= _rating;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _rating = starValue);
                              HapticFeedback.selectionClick();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFilled ? AppColors.starAmber : Colors.grey.shade300,
                                size: 38,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRatingLabel(_rating),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Reviewer Name Field
                const Text(
                  'Your Display Name:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Aisha M. or Engr. Ibrahim',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide your name or initials';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Review Title Field
                const Text(
                  'Review Headline / Title:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Magnificent Oud Sillage, Non-Tarnish Gold',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),

                const SizedBox(height: 14),

                // Detailed Comment Text Field
                const Text(
                  'Detailed Experience & Craftsmanship Feedback:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Share fragrance longevity, ring comfort fit, crystal sparkle, gold weight, or packaging elegance...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.4),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Please provide at least a short sentence of feedback';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Experience Tag Chips
                const Text(
                  'Highlight Key Highlights (Optional):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surfaceMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'Publishing Review...' : 'Submit Verified Review',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
