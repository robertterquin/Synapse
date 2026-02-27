import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_profile.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final UserProfile profile;
  final bool showHospitalLabels;
  final ValueChanged<bool>? onShowHospitalLabelsChanged;

  const SettingsPage({
    super.key,
    required this.profile,
    this.showHospitalLabels = true,
    this.onShowHospitalLabelsChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _showHospitalLabels;

  @override
  void initState() {
    super.initState();
    _showHospitalLabels = widget.showHospitalLabels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.lavenderHaze),
                    ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.lavenderHaze,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display section
                        _buildSectionHeader(
                            Icons.map_rounded, 'Display'),
                        const SizedBox(height: 10),
                        _buildCard(children: [
                          _buildToggleTile(
                            icon: Icons.label_rounded,
                            iconColor: AppColors.twilightPurple,
                            title: 'Hospital Labels',
                            subtitle: 'Show name labels on map pins',
                            value: _showHospitalLabels,
                            onChanged: (v) {
                              setState(() => _showHospitalLabels = v);
                              widget.onShowHospitalLabelsChanged?.call(v);
                            },
                          ),
                        ]),
                        const SizedBox(height: 40),

                        // Logout button
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.twilightPurple),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.twilightPurple,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  // ── Account card ─────────────────────────────────────────────────────────────

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightIndigo.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider.withValues(alpha: 0.5),
      indent: 56,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _tileIcon(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark.withValues(alpha: 0.5),
                    )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.twilightPurple,
            activeTrackColor:
                AppColors.twilightPurple.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _tileIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  // ── Logout button ─────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded,
            color: Color(0xFFFF6B6B), size: 18),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFFF6B6B),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.nightIndigo)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: AppColors.textDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.twilightPurple)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
