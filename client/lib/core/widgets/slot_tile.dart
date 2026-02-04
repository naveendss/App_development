import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SlotTile extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  const SlotTile({
    super.key,
    required this.time,
    required this.isAvailable,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : isAvailable
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : isAvailable
                          ? Icons.radio_button_unchecked
                          : Icons.block,
                  color: isSelected
                      ? Colors.black
                      : isAvailable
                          ? AppTheme.primaryColor
                          : Colors.white38,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isSelected
                  ? 'SELECTED'
                  : isAvailable
                      ? 'AVAILABLE'
                      : 'FULL',
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : isAvailable
                        ? AppTheme.primaryColor
                        : Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
