import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_profile.dart';
import '../screens/profile_page.dart';
import '../screens/hospital_status_page.dart';

class SidebarNavigation extends StatelessWidget {
  final UserProfile profile;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const SidebarNavigation({
    super.key,
    required this.profile,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0042),
            AppColors.nightIndigo,
            AppColors.twilightPurple,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightIndigo.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 22),

            // Nav items
            _buildNavItem(context, index: 0,
                icon: Icons.map_rounded, label: 'Map'),
            const SizedBox(height: 2),
            _buildNavItem(context, index: 1,
                icon: Icons.person_rounded, label: 'Profile',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => ProfilePage(profile: profile)))),
            const SizedBox(height: 2),
            _buildNavItem(context, index: 2,
                icon: Icons.local_hospital_rounded, label: 'Status',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HospitalStatusPage(profile: profile)))),

            const Spacer(),

            // Divider
            _buildDivider(),
            const SizedBox(height: 8),

            _buildNavItem(context, index: 3,
                icon: Icons.settings_rounded, label: 'Settings'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.duskyBlue.withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap ?? () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.duskyBlue.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left glow indicator strip for selected
            if (isSelected)
              Positioned(
                left: 0,
                top: 6,
                bottom: 6,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppColors.duskyBlue,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.duskyBlue.withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.lavenderHaze
                        : AppColors.lavenderHaze.withValues(alpha: 0.38),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? AppColors.lavenderHaze
                        : AppColors.lavenderHaze.withValues(alpha: 0.38),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
