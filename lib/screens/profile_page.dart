import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';
import '../services/hospital_manager.dart';
import '../widgets/status_update_dialog.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final HospitalManager _manager = HospitalManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  UserProfile get profile => widget.profile;

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
                        'My Profile',
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

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.duskyBlue, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                AppColors.lavenderHaze.withValues(alpha: 0.5),
                            child: const Icon(Icons.person,
                                size: 56, color: AppColors.twilightPurple),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nightIndigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: profile.isVerified
                                ? AppColors.pinGreen.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.isVerified
                                    ? Icons.verified
                                    : Icons.pending,
                                size: 16,
                                color: profile.isVerified
                                    ? AppColors.pinGreen
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile.isVerified
                                    ? 'Verified'
                                    : 'Pending Verification',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: profile.isVerified
                                      ? AppColors.pinGreen
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Info cards
                        _buildInfoCard(
                          Icons.local_hospital,
                          'Hospital',
                          profile.hospital,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          Icons.badge,
                          'ID Number',
                          profile.idNumber,
                        ),
                        const SizedBox(height: 12),
                        if (profile.specialization != null) ...[
                          _buildInfoCard(
                            Icons.school,
                            'Specialization',
                            profile.specialization!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _buildInfoCard(
                          Icons.verified_user,
                          'ID Verification',
                          profile.isVerified
                              ? 'PRC License verified on ${DateTime.now().toString().split(' ')[0]}'
                              : 'Not yet verified',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          Icons.location_on,
                          'Current Assignment',
                          profile.assignedHospital ?? 'No current assignment',
                        ),
                        const SizedBox(height: 32),

                        // Assigned Hospital Status section
                        _buildAssignedHospitalStatus(),
                        const SizedBox(height: 16),

                        // Employment status section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.twilightPurple,
                                AppColors.midnightBlue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Employment Status',
                                style: TextStyle(
                                  color: AppColors.lavenderHaze,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Open to receiving hospital assignment requests',
                                style: TextStyle(
                                  color: AppColors.lavenderHaze,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildAssignedHospitalStatus() {
    final hospital = profile.assignedHospitalObj;
    if (hospital == null) {
      return const SizedBox.shrink();
    }

    final status = hospital.status;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(status.icon, color: status.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Hospital Status',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.midnightBlue.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick stats
          Row(
            children: [
              _buildMiniStat('Staff', '${hospital.staff}'),
              const SizedBox(width: 8),
              _buildMiniStat('Patients', '${hospital.patients}'),
              const SizedBox(width: 8),
              _buildMiniStat('Beds', '${hospital.availableBeds}'),
              const SizedBox(width: 8),
              _buildMiniStat('Ratio', hospital.ratioDisplay),
            ],
          ),
          const SizedBox(height: 12),
          // Update button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () =>
                  showStatusUpdateDialog(context, hospital),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text(
                'Update Hospital Status',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: status.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.nightIndigo,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: AppColors.midnightBlue.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lavenderHaze.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.twilightPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(icon, color: AppColors.twilightPurple, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.midnightBlue.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.nightIndigo,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
