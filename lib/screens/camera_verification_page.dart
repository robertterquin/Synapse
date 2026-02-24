import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_profile.dart';
import 'dashboard_page.dart';

class CameraVerificationPage extends StatefulWidget {
  final UserProfile profile;

  const CameraVerificationPage({super.key, required this.profile});

  @override
  State<CameraVerificationPage> createState() => _CameraVerificationPageState();
}

class _CameraVerificationPageState extends State<CameraVerificationPage>
    with SingleTickerProviderStateMixin {
  bool _captured = false;
  bool _verifying = false;
  bool _verified = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    setState(() => _captured = true);

    // Simulate verification delay
    setState(() => _verifying = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _verifying = false;
      _verified = true;
      widget.profile.isVerified = true;
      widget.profile.assignedHospital = widget.profile.hospital;
    });
  }

  void _proceedToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(profile: widget.profile),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.lavenderHaze),
                    ),
                    const Expanded(
                      child: Text(
                        'ID Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lavenderHaze,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Capture your PRC License or Professional ID\nfor credential verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.duskyBlue.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Camera viewfinder area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _verified
                            ? AppColors.pinGreen
                            : AppColors.duskyBlue.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: _buildCameraContent(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status indicator
                if (_verifying)
                  const Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.duskyBlue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Verifying credentials...',
                        style: TextStyle(
                          color: AppColors.lavenderHaze,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                else if (_verified)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.pinGreen,
                        ),
                        child:
                            const Icon(Icons.check, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Verification Successful!',
                        style: TextStyle(
                          color: AppColors.pinGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _proceedToDashboard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.duskyBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Dashboard',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Capture button
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.lavenderHaze,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.duskyBlue.withValues(
                                    alpha: 0.3 + (_pulseController.value * 0.3)),
                                blurRadius: 20 + (_pulseController.value * 10),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lavenderHaze,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.nightIndigo,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    if (_captured) {
      // Simulated captured ID
      return Stack(
        children: [
          Container(
            color: const Color(0xFFF5F5DC),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.badge,
                    size: 80,
                    color: AppColors.twilightPurple.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'PROFESSIONAL REGULATION COMMISSION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nightIndigo,
                          ),
                        ),
                        const Divider(),
                        Text(
                          widget.profile.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nightIndigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'License No: ${widget.profile.idNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.midnightBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.profile.hospital,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.midnightBlue.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay scan lines
          if (_verifying)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Positioned(
                  top: _pulseController.value *
                      MediaQuery.of(context).size.height *
                      0.4,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: AppColors.duskyBlue.withValues(alpha: 0.8),
                  ),
                );
              },
            ),
        ],
      );
    }

    // Camera preview simulation
    return Stack(
      children: [
        Container(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.credit_card,
                  size: 64,
                  color: AppColors.duskyBlue.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Position your PRC License\nwithin the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.lavenderHaze.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Corner markers
        ..._buildCornerMarkers(),
      ],
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerLength = 40.0;
    const markerWidth = 3.0;
    const color = AppColors.duskyBlue;
    const padding = 40.0;

    return [
      // Top-left
      Positioned(
        top: padding,
        left: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: markerLength, height: markerWidth, color: color),
            Container(
                width: markerWidth,
                height: markerLength - markerWidth,
                color: color),
          ],
        ),
      ),
      // Top-right
      Positioned(
        top: padding,
        right: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: markerLength, height: markerWidth, color: color),
            Container(
                width: markerWidth,
                height: markerLength - markerWidth,
                color: color),
          ],
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: padding,
        left: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: markerWidth,
                height: markerLength - markerWidth,
                color: color),
            Container(width: markerLength, height: markerWidth, color: color),
          ],
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: padding,
        right: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                width: markerWidth,
                height: markerLength - markerWidth,
                color: color),
            Container(width: markerLength, height: markerWidth, color: color),
          ],
        ),
      ),
    ];
  }
}
