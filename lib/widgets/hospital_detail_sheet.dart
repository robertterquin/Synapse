import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';
import '../services/hospital_manager.dart';
import 'status_update_dialog.dart';

class HospitalDetailSheet extends StatelessWidget {
  final Hospital hospital;
  final UserProfile? profile;

  const HospitalDetailSheet({
    super.key,
    required this.hospital,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hospital.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hospital.status.color.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(hospital.status.icon,
                      color: hospital.status.color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    hospital.status.label,
                    style: TextStyle(
                      color: hospital.status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hospital name
            Text(
              hospital.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.nightIndigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hospital.isGeneral ? 'General Hospital' : 'Specialized Hospital',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.twilightPurple.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Staff:Patient ratio
            Row(
              children: [
                Icon(Icons.groups, size: 16,
                    color: AppColors.midnightBlue.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(
                  'Staff:Patient Ratio — ${hospital.ratioDisplay}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.midnightBlue.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats grid
            _buildStatsGrid(),

            const SizedBox(height: 20),

            // Update Status button (only for assigned hospital)
            if (profile != null && profile!.isAssignedTo(hospital)) ...[              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showStatusUpdateDialog(context, hospital);
                  },
                  icon: const Icon(Icons.edit_note, size: 22),
                  label: const Text(
                    'Update Hospital Status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duskyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Conditional sections based on status
            ..._buildStatusSpecificContent(context),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lavenderHaze.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem(Icons.people, '${hospital.staff}', 'Staff'),
            _buildDivider(),
            _buildStatItem(Icons.personal_injury, '${hospital.patients}', 'Patients'),
            _buildDivider(),
            _buildStatItem(Icons.bed, '${hospital.availableBeds}', 'Beds'),
            _buildDivider(),
            _buildStatItem(
                Icons.meeting_room, '${hospital.availableRooms}', 'Rooms'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.twilightPurple, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.nightIndigo,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.midnightBlue.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.divider,
    );
  }

  List<Widget> _buildStatusSpecificContent(BuildContext context) {
    final widgets = <Widget>[];

    // Staff needed — Red, Blue pins
    if (hospital.needsStaff && hospital.compensation != null) {
      widgets.add(_buildSectionCard(
        icon: Icons.monetization_on,
        iconColor: AppColors.pinGreen,
        title: 'Compensation Offered',
        content: '₱${hospital.compensation!.toStringAsFixed(0)}/month',
        contentStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.pinGreen,
        ),
      ));
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _showCredentialSubmission(context),
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'Accept & Submit Credentials',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.twilightPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    // Low beds / patient surge — Red, Yellow, Orange pins
    if (hospital.hasLowBeds || hospital.hasPatientSurge) {
      if (hospital.nearestReferral != null) {
        widgets.add(_buildSectionCard(
          icon: Icons.alt_route,
          iconColor: AppColors.duskyBlue,
          title: 'Nearest Referral Hospital',
          content: hospital.nearestReferral!,
          contentStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.midnightBlue,
          ),
          subtitle:
              'This hospital can accommodate patients. Auto-searched based on proximity and bed availability.',
        ));
        widgets.add(const SizedBox(height: 16));
      }
    }

    // Specialized doctors needed — Pink pins
    if (hospital.status == HospitalStatus.needSpecialized &&
        hospital.specialistNeeded != null) {
      widgets.add(_buildSectionCard(
        icon: Icons.medical_services,
        iconColor: AppColors.pinPink,
        title: 'Specialist Required',
        content: hospital.specialistNeeded!,
        contentStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.pinPink,
        ),
        subtitle:
            'All registered doctors matching this specialization will be notified.',
      ));
      widgets.add(const SizedBox(height: 12));
      if (hospital.compensation != null) {
        widgets.add(_buildSectionCard(
          icon: Icons.monetization_on,
          iconColor: AppColors.pinGreen,
          title: 'Compensation',
          content: '₱${hospital.compensation!.toStringAsFixed(0)}/month',
          contentStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.pinGreen,
          ),
        ));
      }
      widgets.add(const SizedBox(height: 16));
      // Accept / Decline buttons for specialists
      widgets.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 17, color: Colors.grey[600]),
                label: Text(
                  'Decline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSpecialistApplication(context),
                icon: const Icon(Icons.check_circle, size: 17),
                label: const Text(
                  'Accept',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    // Normal status — Green pins
    if (hospital.status == HospitalStatus.normal) {
      widgets.add(_buildSectionCard(
        icon: Icons.check_circle,
        iconColor: AppColors.pinGreen,
        title: 'Operational Status',
        content: 'Operating Normally',
        contentStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.pinGreen,
        ),
        subtitle: 'All services available. Adequate staffing and bed capacity.',
      ));
    }

    return widgets;
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required TextStyle contentStyle,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: contentStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCredentialSubmission(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CredentialSubmissionDialog(hospital: hospital),
    );
  }

  void _showSpecialistApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _SpecialistApplicationDialog(hospital: hospital),
    );
  }
}

class _CredentialSubmissionDialog extends StatefulWidget {
  final Hospital hospital;

  const _CredentialSubmissionDialog({required this.hospital});

  @override
  State<_CredentialSubmissionDialog> createState() =>
      _CredentialSubmissionDialogState();
}

class _CredentialSubmissionDialogState
    extends State<_CredentialSubmissionDialog> {
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _specController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildSuccessContent() : _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.twilightPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_ind,
                color: AppColors.twilightPurple, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Submit Credentials',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.nightIndigo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'For review by ${widget.hospital.name}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildTextField(_nameController, 'Full Name', Icons.person),
          const SizedBox(height: 12),
          _buildTextField(
              _licenseController, 'PRC License Number', Icons.badge),
          const SizedBox(height: 12),
          _buildTextField(_specController, 'Specialization', Icons.school),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() => _submitted = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.twilightPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Submit for Review',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.pinGreen, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Credentials Submitted!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.nightIndigo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your credentials have been submitted to\n${widget.hospital.name}\nfor review.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.duskyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.twilightPurple, size: 20),
        filled: true,
        fillColor: AppColors.lavenderHaze.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.twilightPurple),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialist Application Dialog
// Shows when a doctor accepts a pink-pin specialist request.
// On submit → clears specialistNeeded → hospital status auto-recomputes.
// ─────────────────────────────────────────────────────────────────────────────

class _SpecialistApplicationDialog extends StatefulWidget {
  final Hospital hospital;

  const _SpecialistApplicationDialog({required this.hospital});

  @override
  State<_SpecialistApplicationDialog> createState() =>
      _SpecialistApplicationDialogState();
}

class _SpecialistApplicationDialogState
    extends State<_SpecialistApplicationDialog> {
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _yearsController = TextEditingController();
  bool _submitted = false;
  HospitalStatus? _newStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _submit() {
    // Clear specialist need → status auto-recomputes
    final manager = HospitalManager();
    manager.clearSpecialistNeed(widget.hospital);
    setState(() {
      _submitted = true;
      _newStatus = widget.hospital.status; // status after clearing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child:
            _submitted ? _buildSuccessContent() : _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pink icon badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pinPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services,
                color: AppColors.pinPink, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Apply as Specialist',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.nightIndigo,
            ),
          ),
          const SizedBox(height: 4),
          // Specialization tag
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pinPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.pinPink.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.hospital.specialistNeeded ?? 'Specialist',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pinPink,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'For ${widget.hospital.name}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildField(_nameController, 'Full Name', Icons.person),
          const SizedBox(height: 12),
          _buildField(
              _licenseController, 'PRC License Number', Icons.badge),
          const SizedBox(height: 12),
          _buildField(
              _yearsController, 'Years of Experience', Icons.work_history),
          const SizedBox(height: 24),
          // Accept / Cancel row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final status = _newStatus;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.pinGreen, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Application Submitted!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.nightIndigo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your credentials have been sent to\n${widget.hospital.name}\nfor review.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        // Show updated hospital status
        if (status != null) ...[         
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: status.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, color: status.color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hospital status updated:',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.duskyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.pinPink, size: 20),
        filled: true,
        fillColor: AppColors.lavenderHaze.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.pinPink),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
