import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 16),
      backgroundColor: color?.withValues(alpha: 0.15),
      side: color == null ? null : BorderSide(color: color!),
    );
  }
}
