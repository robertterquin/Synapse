import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../constants/app_colors.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';
import '../services/hospital_manager.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/hospital_detail_sheet.dart';
import '../widgets/status_update_dialog.dart';

class DashboardPage extends StatefulWidget {
  final UserProfile profile;

  const DashboardPage({super.key, required this.profile});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _sidebarIndex = 0;
  Hospital? _selectedHospital;
  bool _legendExpanded = true;
  final MapController _mapController = MapController();
  final HospitalManager _manager = HospitalManager();

  // Metro Manila center
  static const _metroManilaCenter = LatLng(14.5995, 120.9842);

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onHospitalDataChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onHospitalDataChanged);
    super.dispose();
  }

  void _onHospitalDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SidebarNavigation(
            profile: widget.profile,
            selectedIndex: _sidebarIndex,
            onItemTapped: (index) => setState(() => _sidebarIndex = index),
          ),

          // Main content
          Expanded(
            child: Stack(
              children: [
                // Map
                _buildMap(),

                // Top bar overlay
                _buildTopBar(),

                // Legend overlay
                _buildLegendOverlay(),

                // Selected hospital card
                if (_selectedHospital != null) _buildSelectedHospitalCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _metroManilaCenter,
        initialZoom: 11.5,
        minZoom: 9,
        maxZoom: 18,
        onTap: (tapPosition, point) {
          setState(() => _selectedHospital = null);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.synapse.app',
        ),
        MarkerLayer(
          markers: _manager.hospitals.map((hospital) {
            return Marker(
              point: LatLng(hospital.latitude, hospital.longitude),
              width: 52,
              height: 52,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedHospital = hospital);
                  _mapController.move(
                    LatLng(hospital.latitude, hospital.longitude),
                    14,
                  );
                },
                child: OverflowBox(
                  maxWidth: 60,
                  maxHeight: 60,
                  child: _buildPin(hospital),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPin(Hospital hospital) {
    final isSelected = _selectedHospital == hospital;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer glow ring on selection
          Container(
            width: isSelected ? 44 : 34,
            height: isSelected ? 44 : 34,
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: hospital.status.color.withValues(alpha: 0.18),
                    border: Border.all(
                      color: hospital.status.color.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  )
                : null,
            child: Center(
              child: Container(
                width: isSelected ? 34 : 30,
                height: isSelected ? 34 : 30,
                decoration: BoxDecoration(
                  color: hospital.status.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isSelected ? 2.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hospital.status.color
                          .withValues(alpha: isSelected ? 0.65 : 0.4),
                      blurRadius: isSelected ? 14 : 6,
                      spreadRadius: isSelected ? 1 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  hospital.status.icon,
                  color: Colors.white,
                  size: isSelected ? 18 : 15,
                ),
              ),
            ),
          ),
          // Pin pointer
          CustomPaint(
            size: const Size(10, 5),
            painter: _PinPointerPainter(hospital.status.color),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.nightIndigo.withValues(alpha: 0.93),
                  AppColors.nightIndigo.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
            child: Row(
              children: [
                // Logo badge with glow
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.duskyBlue, AppColors.twilightPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.duskyBlue.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.lavenderHaze, AppColors.duskyBlue],
                        ).createShader(bounds),
                        child: const Text(
                          'SYNAPSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'DOH Metro Manila Hospital Network',
                        style: TextStyle(
                          color: AppColors.duskyBlue,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // Active hospitals pill badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.pinGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.pinGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.pinGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_manager.hospitals.length} Active',
                        style: const TextStyle(
                          color: AppColors.pinGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
    );
  }

  Widget _buildLegendOverlay() {
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;
    return Positioned(
      bottom: bottomPad,
      left: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 210),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.nightIndigo.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.duskyBlue.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with collapse toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _legendExpanded = !_legendExpanded),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.duskyBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'PIN LEGEND',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                color: AppColors.lavenderHaze,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _legendExpanded ? 0 : 0.5,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color:
                                  AppColors.lavenderHaze.withValues(alpha: 0.5),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Collapsible items
                  AnimatedCrossFade(
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        children: [
                          _buildLegendItem(
                              AppColors.pinPink, 'Specialized Needed'),
                          _buildLegendItem(
                              AppColors.pinRed, 'Critical: All 3 Conditions'),
                          _buildLegendItem(
                              AppColors.pinOrange, 'Patient Surge'),
                          _buildLegendItem(AppColors.pinBlue, 'Need Staff'),
                          _buildLegendItem(
                              AppColors.pinYellow, 'Low Bed Availability'),
                          _buildLegendItem(
                              AppColors.pinGreen, 'Normal Status'),
                        ],
                      ),
                    ),
                    secondChild:
                        const SizedBox(height: 0, width: double.infinity),
                    crossFadeState: _legendExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 220),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.lavenderHaze.withValues(alpha: 0.85),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedHospitalCard() {
    final hospital = _selectedHospital!;
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return Positioned(
      bottom: bottomPad,
      right: 12,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 96,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: hospital.status.color.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Colored header strip
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      hospital.status.color,
                      hospital.status.color.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hospital.status.icon,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        hospital.status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedHospital = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.nightIndigo,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.duskyBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hospital.isGeneral ? 'General' : 'Specialized',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.duskyBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.groups,
                            size: 13,
                            color:
                                AppColors.midnightBlue.withValues(alpha: 0.45)),
                        const SizedBox(width: 3),
                        Text(
                          'Ratio ${hospital.ratioDisplay}',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                AppColors.midnightBlue.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stats row with accent colors
                    Row(
                      children: [
                        _buildQuickStat(
                            'Staff', '${hospital.staff}', AppColors.duskyBlue),
                        const SizedBox(width: 6),
                        _buildQuickStat('Patients', '${hospital.patients}',
                            AppColors.pinOrange),
                        const SizedBox(width: 6),
                        _buildQuickStat(
                            'Beds', '${hospital.availableBeds}', AppColors.pinGreen),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardButton(
                            'View Details',
                            Icons.info_outline_rounded,
                            AppColors.twilightPurple,
                            () => _showHospitalDetails(hospital),
                          ),
                        ),
                        if (widget.profile.isAssignedTo(hospital)) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCardButton(
                              'Update',
                              Icons.edit_note_rounded,
                              AppColors.duskyBlue,
                              () => showStatusUpdateDialog(context, hospital),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: accent,
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
                fontWeight: FontWeight.w500,
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

  void _showHospitalDetails(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return HospitalDetailSheet(
            hospital: hospital,
            profile: widget.profile,
          );
        },
      ),
    );
  }
}

class _PinPointerPainter extends CustomPainter {
  final Color color;

  _PinPointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
