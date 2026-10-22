import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconAsset;
  final IconData fallbackIcon;
  final Color backgroundColor;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconAsset = '',
    required this.fallbackIcon,
    this.backgroundColor = const Color(0xFFF4EFE6),
  });
}
