import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_colors.dart';

class TikTokNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadNotificationCount;

  const TikTokNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadNotificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Color(0xFF1E1E24), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_filled,
              outlineIcon: Icons.home_outlined,
              label: 'Beranda',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.people,
              outlineIcon: Icons.people_outline,
              label: 'Teman',
            ),
            _buildAddButton(),
            _buildNavItem(
              index: 3,
              icon: Icons.chat_bubble,
              outlineIcon: Icons.chat_bubble_outline,
              label: 'Kotak Masuk',
              showBadge: unreadNotificationCount > 0,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person,
              outlineIcon: Icons.person_outline,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlineIcon,
    required String label,
    bool showBadge = false,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.textPrimary : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? icon : outlineIcon,
                  size: 25,
                  color: color,
                ),
                if (showBadge)
                  Positioned(
                    right: -3,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.badgeRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: SizedBox(
        width: 48,
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left Cyan background
            Positioned(
              left: 2,
              child: Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Right Pink background
            Positioned(
              right: 2,
              child: Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Center Dark foreground button
            Container(
              width: 38,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

