import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberDetailGridItem {
  final IconData icon;
  final String label;
  final String value;

  const CyberDetailGridItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class CyberDetailGrid extends StatelessWidget {
  final List<CyberDetailGridItem> items;
  final int crossAxisCount;
  final double childAspectRatio;

  const CyberDetailGrid({
    super.key,
    required this.items,
    this.crossAxisCount    = 2,
    this.childAspectRatio  = 2.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: childAspectRatio,
      children: items.map(_buildCell).toList(),
    );
  }

  Widget _buildCell(CyberDetailGridItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 17, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
                Text(
                  item.value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}