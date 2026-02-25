import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';
import '../services/hospital_manager.dart';
import '../widgets/status_update_dialog.dart';

class HospitalStatusPage extends StatefulWidget {
  final UserProfile? profile;

  const HospitalStatusPage({super.key, this.profile});

  @override
  State<HospitalStatusPage> createState() => _HospitalStatusPageState();
}

class _HospitalStatusPageState extends State<HospitalStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _followedHospitals = {};
  final HospitalManager _manager = HospitalManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<Hospital> _getFilteredHospitals(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return _manager.hospitals
            .where((h) => h.type == HospitalType.specialized)
            .toList();
      case 2:
        return _manager.hospitals
            .where((h) => h.type == HospitalType.general)
            .toList();
      default:
        return _manager.hospitals;
    }
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
                        'Hospital Status',
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

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  indicator: BoxDecoration(
                    color: AppColors.duskyBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.lavenderHaze,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Specialized'),
                    Tab(text: 'General'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildLegendChip(AppColors.pinGreen, 'Normal'),
                    _buildLegendChip(AppColors.pinYellow, 'Low Beds'),
                    _buildLegendChip(AppColors.pinOrange, 'Surge'),
                    _buildLegendChip(AppColors.pinBlue, 'Need Staff'),
                    _buildLegendChip(AppColors.pinRed, 'Critical'),
                    _buildLegendChip(AppColors.pinPink, 'Specialist'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Hospital list
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final hospitals =
                          _getFilteredHospitals(_tabController.index);
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        itemCount: hospitals.length,
                        itemBuilder: (context, index) {
                          return _buildHospitalCard(hospitals[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    final isFollowed = _followedHospitals.contains(hospital.name);
    final ratio = hospital.patients > 0
        ? '1:${(hospital.patients / hospital.staff).toStringAsFixed(1)}'
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hospital.status.color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: hospital.status.color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hospital.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hospital.status.icon,
                    color: hospital.status.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.nightIndigo,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: hospital.isGeneral
                                  ? AppColors.duskyBlue.withValues(alpha: 0.1)
                                  : AppColors.twilightPurple
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hospital.isGeneral ? 'General' : 'Specialized',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: hospital.isGeneral
                                    ? AppColors.duskyBlue
                                    : AppColors.twilightPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: hospital.status.color
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hospital.status.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: hospital.status.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (isFollowed) {
                        _followedHospitals.remove(hospital.name);
                      } else {
                        _followedHospitals.add(hospital.name);
                      }
                    });
                  },
                  icon: Icon(
                    isFollowed ? Icons.star : Icons.star_border,
                    color:
                        isFollowed ? Colors.amber : AppColors.midnightBlue,
                  ),
                  tooltip: isFollowed ? 'Unfollow' : 'Follow for updates',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _buildMiniStat(Icons.people, 'Staff:Patient', ratio),
                const SizedBox(width: 12),
                _buildMiniStat(
                    Icons.bed, 'Beds', '${hospital.availableBeds}'),
                const SizedBox(width: 12),
                _buildMiniStat(
                    Icons.meeting_room, 'Rooms', '${hospital.availableRooms}'),
              ],
            ),

            // Update button for assigned hospital
            if (widget.profile != null &&
                widget.profile!.isAssignedTo(hospital)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showStatusUpdateDialog(context, hospital),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text(
                    'Update Status',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duskyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.lavenderHaze.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.twilightPurple),
            const SizedBox(height: 4),
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
                color: AppColors.midnightBlue.withValues(alpha: 0.6),
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
}
