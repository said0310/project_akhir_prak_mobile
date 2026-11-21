import 'package:flutter/material.dart';
import '../app.dart';
import '../models/models.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? WijiBumiColors.textWhite
                    : WijiBumiColors.textMutedLight,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            // Indikator tab aktif: garis putih horizontal lebar 18 px, tinggi 2.5 px, radius 2 px
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 18 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: WijiBumiColors.textWhite,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
