import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Animated popup that displays "Sending signals through Synapse…"
/// with pulsing signal rings. Auto-dismisses after ~2.5 seconds.
class SynapseSignalDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const SynapseSignalDialog({super.key, required this.onComplete});

  @override
  State<SynapseSignalDialog> createState() => _SynapseSignalDialogState();
}

class _SynapseSignalDialogState extends State<SynapseSignalDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.nightIndigo, AppColors.twilightPurple],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.twilightPurple.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing signal rings
            SizedBox(
              width: 130,
              height: 130,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 110 + (_controller.value * 20),
                        height: 110 + (_controller.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.duskyBlue.withValues(
                                alpha: 0.15 * (1 - _controller.value)),
                            width: 2,
                          ),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 80 + (_controller.value * 15),
                        height: 80 + (_controller.value * 15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.duskyBlue.withValues(
                                alpha: 0.35 * (1 - _controller.value)),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner ring
                      Container(
                        width: 55 + (_controller.value * 10),
                        height: 55 + (_controller.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.duskyBlue.withValues(
                                alpha: 0.5 * (1 - _controller.value)),
                            width: 2,
                          ),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.duskyBlue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cell_tower,
                          color: AppColors.lavenderHaze,
                          size: 30,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sending signals\nthrough Synapse…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lavenderHaze,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Updating hospital network status',
              style: TextStyle(
                color: AppColors.duskyBlue.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the "Sending signals through Synapse…" animated popup.
/// Returns a Future that completes after the animation finishes.
Future<void> showSynapseSignal(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (dialogContext) => SynapseSignalDialog(
      onComplete: () => Navigator.of(dialogContext).pop(),
    ),
  );
}
