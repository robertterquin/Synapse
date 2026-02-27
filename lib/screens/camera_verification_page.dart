import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../models/user_profile.dart';
import 'dashboard_page.dart';

class CameraVerificationPage extends StatefulWidget {
  final UserProfile profile;

  const CameraVerificationPage({super.key, required this.profile});

  @override
  State<CameraVerificationPage> createState() => _CameraVerificationPageState();
}

enum _Step { idle, scanning, verified }

class _CameraVerificationPageState extends State<CameraVerificationPage>
    with TickerProviderStateMixin {
  _Step _step = _Step.idle;
  XFile? _image;

  late AnimationController _scanCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _checkCtrl;

  late Animation<double> _scanAnim;
  late Animation<double> _checkAnim;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo == null || !mounted) return;
    setState(() {
      _image = photo;
      _step = _Step.scanning;
    });
    _runScan();
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (photo == null || !mounted) return;
    setState(() {
      _image = photo;
      _step = _Step.scanning;
    });
    _runScan();
  }

  Future<void> _runScan() async {
    // Two scan passes
    _scanCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;
    _scanCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;
    setState(() {
      _step = _Step.verified;
      widget.profile.isVerified = true;
      widget.profile.assignedHospital = widget.profile.hospital;
    });
    _checkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) _proceedToDashboard();
  }

  void _proceedToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => DashboardPage(profile: widget.profile)),
      (route) => false,
    );
  }

  void _retake() {
    setState(() {
      _image = null;
      _step = _Step.idle;
    });
    _scanCtrl.reset();
    _checkCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 24),
                Expanded(child: _buildViewfinder()),
                const SizedBox(height: 28),
                _buildBottomSection(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.lavenderHaze, size: 20),
        ),
        const Expanded(
          child: Text(
            'ID Verification',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.lavenderHaze,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildSubtitle() {
    final text = switch (_step) {
      _Step.idle =>
        'Take a photo or upload your PRC License\nor Professional ID',
      _Step.scanning => 'Scanning your credentials...',
      _Step.verified => 'Identity verified!',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.duskyBlue.withValues(alpha: 0.85),
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  // â”€â”€ Viewfinder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildViewfinder() {
    final borderColor = _step == _Step.verified
        ? AppColors.pinGreen
        : _step == _Step.scanning
            ? AppColors.duskyBlue
            : AppColors.duskyBlue.withValues(alpha: 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: borderColor.withValues(alpha: 0.28), blurRadius: 22),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _image == null ? _buildIdleFrame() : _buildImageFrame(),
      ),
    );
  }

  Widget _buildIdleFrame() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF0D0D1E)),
        CustomPaint(painter: _GridPainter()),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card_rounded,
                  size: 56,
                  color: AppColors.duskyBlue.withValues(alpha: 0.22)),
              const SizedBox(height: 14),
              Text(
                'Position your ID within the frame',
                style: TextStyle(
                  color: AppColors.lavenderHaze.withValues(alpha: 0.28),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ..._corners(),
      ],
    );
  }

  Widget _buildImageFrame() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Real captured photo
        Image.network(
          _image!.path,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => Container(
            color: const Color(0xFF0D0D1E),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: Colors.white54, size: 48),
            ),
          ),
        ),

        // Dark tint while scanning
        if (_step == _Step.scanning)
          Container(color: Colors.black.withValues(alpha: 0.2)),

        // Animated scan line
        if (_step == _Step.scanning) _buildScanLine(),

        // Data overlay during scan
        if (_step == _Step.scanning) _buildDataOverlay(),

        // Verified check
        if (_step == _Step.verified) _buildVerifiedOverlay(),
      ],
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanAnim,
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints) {
          final y = _scanAnim.value * constraints.maxHeight;
          return Stack(
            children: [
              // Main glow line
              Positioned(
                top: y - 1,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.duskyBlue.withValues(alpha: 0.9),
                        AppColors.lavenderHaze,
                        AppColors.duskyBlue.withValues(alpha: 0.9),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.duskyBlue.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Soft fade-trailing
              Positioned(
                top: y,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.duskyBlue.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildDataOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.nightIndigo.withValues(alpha: 0.78),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataRow('NAME', widget.profile.name.toUpperCase()),
                const SizedBox(height: 5),
                _dataRow('ID NO', widget.profile.idNumber),
                const SizedBox(height: 5),
                _dataRow('HOSPITAL', widget.profile.hospital),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataRow(String key, String value) {
    return Row(
      children: [
        Text(
          '$key  ',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.duskyBlue.withValues(alpha: 0.7),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.lavenderHaze,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedOverlay() {
    return Center(
      child: ScaleTransition(
        scale: _checkAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.pinGreen.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: AppColors.pinGreen.withValues(alpha: 0.55),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
        ),
      ),
    );
  }

  // â”€â”€ Corner frame markers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<Widget> _corners() {
    const c = AppColors.duskyBlue;
    const len = 34.0;
    const w = 2.5;
    const pad = 22.0;
    return [
      Positioned(
          top: pad,
          left: pad,
          child: _Corner(len: len, w: w, color: c, fx: false, fy: false)),
      Positioned(
          top: pad,
          right: pad,
          child: _Corner(len: len, w: w, color: c, fx: true, fy: false)),
      Positioned(
          bottom: pad,
          left: pad,
          child: _Corner(len: len, w: w, color: c, fx: false, fy: true)),
      Positioned(
          bottom: pad,
          right: pad,
          child: _Corner(len: len, w: w, color: c, fx: true, fy: true)),
    ];
  }

  // â”€â”€ Bottom section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildBottomSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (_step) {
        _Step.idle => _buildIdleButtons(),
        _Step.scanning => _buildScanningStatus(),
        _Step.verified => _buildVerifiedStatus(),
      },
    );
  }

  Widget _buildIdleButtons() {
    return Column(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing shutter button
        GestureDetector(
          onTap: _pickFromCamera,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lavenderHaze.withValues(alpha: 0.65),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.duskyBlue.withValues(
                          alpha: 0.25 + _pulseCtrl.value * 0.28),
                      blurRadius: 18 + _pulseCtrl.value * 12,
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
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.nightIndigo, size: 28),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: _pickFromGallery,
          icon: Icon(Icons.upload_file_rounded,
              size: 17,
              color: AppColors.duskyBlue.withValues(alpha: 0.75)),
          label: Text(
            'Upload from gallery',
            style: TextStyle(
              color: AppColors.duskyBlue.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningStatus() {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
              color: AppColors.duskyBlue, strokeWidth: 2.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Scanning credentials...',
          style: TextStyle(
            color: AppColors.lavenderHaze.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _retake,
          child: Text(
            'Retake',
            style: TextStyle(
                color: AppColors.duskyBlue.withValues(alpha: 0.55),
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedStatus() {
    return Column(
      key: const ValueKey('verified'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded,
                color: AppColors.pinGreen, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Verification Successful',
              style: TextStyle(
                color: AppColors.pinGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Redirecting to dashboard...',
          style: TextStyle(
            color: AppColors.lavenderHaze.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Corner mark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Corner extends StatelessWidget {
  final double len;
  final double w;
  final Color color;
  final bool fx;
  final bool fy;

  const _Corner(
      {required this.len,
      required this.w,
      required this.color,
      required this.fx,
      required this.fy});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: fx ? -1 : 1,
      scaleY: fy ? -1 : 1,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: len,
        height: len,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                child: Container(width: len, height: w, color: color)),
            Positioned(
                top: 0,
                left: 0,
                child: Container(width: w, height: len, color: color)),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Subtle grid background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.duskyBlue.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

