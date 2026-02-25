import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/hospitals_data.dart';
import '../models/user_profile.dart';
import 'camera_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedHospital;
  final _idNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserProfile(
      name: _nameController.text,
      hospital: _selectedHospital!,
      idNumber: _idNumberController.text,
      specialization: _specializationController.text.isNotEmpty
          ? _specializationController.text
          : null,
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => CameraVerificationPage(profile: profile)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: Stack(
          children: [
            // Decorative blur orbs
            Positioned(
              top: -80,
              right: -80,
              child: _Orb(size: 280, color: AppColors.duskyBlue, opacity: 0.18),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _Orb(size: 320, color: AppColors.twilightPurple, opacity: 0.22),
            ),
            Positioned(
              top: 200,
              left: -60,
              child: _Orb(size: 160, color: AppColors.duskyBlue, opacity: 0.10),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo badge
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.duskyBlue,
                                AppColors.twilightPurple
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.duskyBlue
                                    .withValues(alpha: 0.5),
                                blurRadius: 24,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // SYNAPSE gradient text
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                            colors: [
                              AppColors.lavenderHaze,
                              AppColors.duskyBlue
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'SYNAPSE',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DOH Metro Manila Hospital Network',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.duskyBlue
                                .withValues(alpha: 0.85),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Glassmorphism form card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.14),
                                ),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Segmented toggle
                                  Container(
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTab('Login', _isLogin),
                                        _buildTab(
                                            'Sign Up', !_isLogin),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Form
                                  FadeTransition(
                                    opacity: _fadeAnim,
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          _buildField(
                                            controller:
                                                _nameController,
                                            label: 'Full Name',
                                            icon: Icons.person_outline_rounded,
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildHospitalDropdown(),
                                          const SizedBox(height: 12),
                                          _buildField(
                                            controller:
                                                _idNumberController,
                                            label: 'ID / PRC Number',
                                            icon: Icons.badge_outlined,
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          if (!_isLogin) ...[
                                            const SizedBox(height: 12),
                                            _buildField(
                                              controller:
                                                  _specializationController,
                                              label:
                                                  'Specialization (optional)',
                                              icon: Icons.school_outlined,
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          _buildField(
                                            controller:
                                                _passwordController,
                                            label: 'Password',
                                            icon: Icons.lock_outline_rounded,
                                            obscure: _obscurePassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors
                                                    .duskyBlue
                                                    .withValues(
                                                        alpha: 0.7),
                                                size: 20,
                                              ),
                                              onPressed: () => setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword),
                                            ),
                                            validator: (v) =>
                                                v == null || v.length < 4
                                                    ? 'Min 4 characters'
                                                    : null,
                                          ),
                                          const SizedBox(height: 24),

                                          // Gradient submit button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 52,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient:
                                                    const LinearGradient(
                                                  colors: [
                                                    AppColors.duskyBlue,
                                                    AppColors.twilightPurple,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .duskyBlue
                                                        .withValues(
                                                            alpha: 0.45),
                                                    blurRadius: 16,
                                                    offset:
                                                        const Offset(
                                                            0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed: _submit,
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                      Colors
                                                          .transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                16),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Text(
                                                      _isLogin
                                                          ? 'Login & Verify'
                                                          : 'Sign Up & Verify',
                                                      style:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                        color:
                                                            Colors.white,
                                                        letterSpacing:
                                                            0.5,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: 8),
                                                    const Icon(
                                                        Icons.arrow_forward_rounded,
                                                        color:
                                                            Colors.white,
                                                        size: 18),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'You will verify your credentials via\ncamera after submitting.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.lavenderHaze
                                .withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalDropdown() {
    final names = metroManilaHospitals.map((h) => h.name).toList()..sort();
    return DropdownButtonFormField<String>(
      value: _selectedHospital,
      isExpanded: true,
      dropdownColor: const Color(0xFF1E0054),
      iconEnabledColor: AppColors.duskyBlue,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Hospital',
        labelStyle: TextStyle(
          color: AppColors.lavenderHaze.withValues(alpha: 0.65),
          fontSize: 13,
        ),
        prefixIcon: Icon(Icons.local_hospital_outlined,
            color: AppColors.duskyBlue.withValues(alpha: 0.85), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.duskyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Colors.orangeAccent, fontSize: 11),
      ),
      hint: Text(
        'Select your hospital',
        style: TextStyle(
            color: AppColors.lavenderHaze.withValues(alpha: 0.45),
            fontSize: 13),
      ),
      items: names
          .map((name) => DropdownMenuItem(
                value: name,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedHospital = value),
      validator: (v) => v == null || v.isEmpty ? 'Please select a hospital' : null,
    );
  }

  Widget _buildTab(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (active) return;
          _toggleMode();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.duskyBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.duskyBlue
                          .withValues(alpha: 0.35),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: active
                    ? Colors.white
                    : AppColors.lavenderHaze
                        .withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
          color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.lavenderHaze.withValues(alpha: 0.65),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon,
            color: AppColors.duskyBlue.withValues(alpha: 0.85),
            size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.duskyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(
            color: Colors.orangeAccent, fontSize: 11),
      ),
    );
  }
}

// Decorative blurred orb
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Orb(
      {required this.size,
      required this.color,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
