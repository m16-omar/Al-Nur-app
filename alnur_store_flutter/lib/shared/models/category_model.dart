import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconAsset;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final String? description;
  final String? tagLine;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconAsset = '',
    required this.fallbackIcon,
    this.backgroundColor = const Color(0xFFF4EFE6),
    this.description,
    this.tagLine,
  });

  static CategoryModel fromId(String id) {
    switch (id.toLowerCase()) {
      case 'perfumes':
        return const CategoryModel(
          id: 'perfumes',
          name: 'Perfumes & Oud',
          fallbackIcon: Icons.spa_rounded,
          backgroundColor: Color(0xFFF5EDF9),
          tagLine: 'ROYAL ARABIAN ATTARS & OUD',
          description:
              'Exquisite pure agarwood oils, ambergris, Taif rose, and artisanal long-lasting alcohol-free Halal perfumes.',
        );
      case 'wedding-rings':
        return const CategoryModel(
          id: 'wedding-rings',
          name: 'Wedding Rings',
          fallbackIcon: Icons.diamond_rounded,
          backgroundColor: Color(0xFFFDF7E7),
          tagLine: 'SACRED BRIDAL EXCELLENCE',
          description:
              'Handcrafted 18k and 24k gold, conflict-free natural diamonds, and timeless bridal eternity bands.',
        );
      case 'wristwatches':
        return const CategoryModel(
          id: 'wristwatches',
          name: 'Wristwatches',
          fallbackIcon: Icons.watch_outlined,
          backgroundColor: Color(0xFFE9F0FA),
          tagLine: 'SWISS & JAPANESE PRECISION',
          description:
              'Luxury stainless steel, sapphire crystal, and precision timepieces designed with dignified modesty.',
        );
      case 'necklaces':
        return const CategoryModel(
          id: 'necklaces',
          name: 'Luxury Necklaces',
          fallbackIcon: Icons.diamond_outlined,
          backgroundColor: Color(0xFFF3E8FF),
          tagLine: 'ARTISANAL CHOKERS & CHAINS',
          description:
              'Regal chokers, multi-layered gold chains, and bespoke gemstone pendants crafted for royal occasions.',
        );
      case 'bangles':
        return const CategoryModel(
          id: 'bangles',
          name: 'Royal Bangles',
          fallbackIcon: Icons.circle_outlined,
          backgroundColor: Color(0xFFFEF3C7),
          tagLine: 'EMBOSSED ARABIAN GOLD CUFFS',
          description:
              'Traditional handcrafted Arabian cuff bangles, embossed gold sets, and bridal wrist jewelry.',
        );
      case 'jewelries':
        return const CategoryModel(
          id: 'jewelries',
          name: 'Fine Jewelry',
          fallbackIcon: Icons.auto_awesome_rounded,
          backgroundColor: Color(0xFFF9EAE1),
          tagLine: 'HAUTE FESTIVE MODESTY SETS',
          description:
              'Complete high-modesty festive jewelry collections, artisanal earrings, and matching luxury bridal sets.',
        );
      case 'rings':
        return const CategoryModel(
          id: 'rings',
          name: 'Rings',
          fallbackIcon: Icons.circle_outlined,
          backgroundColor: Color(0xFFE8F1EC),
          tagLine: 'STATEMENT & SOLITAIRE BANDS',
          description:
              'Solitaire statement rings, vintage emerald cuts, and everyday luxury modest bands.',
        );
      case 'abayas':
        return const CategoryModel(
          id: 'abayas',
          name: 'Luxury Abayas',
          fallbackIcon: Icons.dry_cleaning_rounded,
          backgroundColor: Color(0xFFF5EFE6),
          tagLine: 'HAUTE MODESTY SILHOUETTES',
          description:
              'Tailored Dubai Noir and Medina crepe abayas with artisanal embroidery and flowing silhouettes.',
        );
      case 'hijabs':
        return const CategoryModel(
          id: 'hijabs',
          name: 'Medina Silk Hijabs',
          fallbackIcon: Icons.all_inclusive_rounded,
          backgroundColor: Color(0xFFEBF3EA),
          tagLine: 'PURE SILK & CHIFFON',
          description:
              'Breathable, non-slip pure Medina silk and chiffon hijabs in rich curated modest color palettes.',
        );
      case 'jalabias':
        return const CategoryModel(
          id: 'jalabias',
          name: 'Moroccan Jalabias',
          fallbackIcon: Icons.stars_rounded,
          backgroundColor: Color(0xFFFBF1EE),
          tagLine: 'FESTIVE EID & JUMUAH ATTIRE',
          description:
              'Royal Moroccan kaftans and festive embroidered jalabias crafted with gold thread sfifa.',
        );
      case 'thobes':
        return const CategoryModel(
          id: 'thobes',
          name: 'Tailored Thobes',
          fallbackIcon: Icons.person_outline_rounded,
          backgroundColor: Color(0xFFEDF2F7),
          tagLine: 'EMIRATI & SAUDI CUTS',
          description:
              'Crisp bespoke Emirati and Saudi cut thobes tailored from premium Japanese cotton and linen blends.',
        );
      default:
        final cleanName = id
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
        return CategoryModel(
          id: id,
          name: cleanName.isNotEmpty ? cleanName : 'Exclusive Collection',
          fallbackIcon: Icons.auto_awesome_rounded,
          backgroundColor: const Color(0xFFF4EFE6),
          tagLine: 'AL-NUR CURATED ATELIER',
          description: 'Explore hand-selected luxury modest creations crafted with timeless elegance.',
        );
    }
  }
}
