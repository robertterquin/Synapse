import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hospital.dart';
import '../services/hospital_manager.dart';
import 'synapse_signal_dialog.dart';

/// Dialog that lets a user update their assigned hospital's statistics.
/// After submission, the status auto-recomputes and the Synapse signal
/// animation plays.
class StatusUpdateDialog extends StatefulWidget {
  final Hospital hospital;

  const StatusUpdateDialog({super.key, required this.hospital});

  @override
  State<StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<StatusUpdateDialog> {
  late TextEditingController _bedsController;
  late TextEditingController _roomsController;
  late TextEditingController _patientsController;
  late TextEditingController _staffController;
  late TextEditingController _specialistController;
  bool _needsSpecialist = false;

  @override
  void initState() {
    super.initState();
    final h = widget.hospital;
    _bedsController = TextEditingController(text: '${h.availableBeds}');
    _roomsController = TextEditingController(text: '${h.availableRooms}');
    _patientsController = TextEditingController(text: '${h.patients}');
    _staffController = TextEditingController(text: '${h.staff}');
    _specialistController =
        TextEditingController(text: h.specialistNeeded ?? '');
    _needsSpecialist =
        h.specialistNeeded != null && h.specialistNeeded!.isNotEmpty;
  }

  @override
  void dispose() {
    _bedsController.dispose();
    _roomsController.dispose();
    _patientsController.dispose();
    _staffController.dispose();
    _specialistController.dispose();
    super.dispose();
  }

  HospitalStatus _previewStatus() {
    final staff = int.tryParse(_staffController.text) ?? widget.hospital.staff;
    final patients =
        int.tryParse(_patientsController.text) ?? widget.hospital.patients;
    final beds =
        int.tryParse(_bedsController.text) ?? widget.hospital.availableBeds;
    final rooms =
        int.tryParse(_roomsController.text) ?? widget.hospital.availableRooms;

    // Simulate auto-classification with the preview values
    final double ratio = staff > 0 ? patients / staff : 0;
    final int totalBeds = beds + rooms;

    if (_needsSpecialist && _specialistController.text.isNotEmpty) {
      return HospitalStatus.needSpecialized;
    }
    if (ratio >= 15 && totalBeds < 20) {
      return HospitalStatus.patientSurgeNeedStaffLowBeds;
    }
    if (ratio >= 20) return HospitalStatus.patientSurge;
    if (ratio >= 15) return HospitalStatus.needStaff;
    if (totalBeds < 20) return HospitalStatus.lowBeds;
    return HospitalStatus.normal;
  }

  void _submitUpdate() {
    final manager = HospitalManager();
    manager.updateHospitalStats(
      hospital: widget.hospital,
      staff: int.tryParse(_staffController.text),
      patients: int.tryParse(_patientsController.text),
      availableBeds: int.tryParse(_bedsController.text),
      availableRooms: int.tryParse(_roomsController.text),
      specialistNeeded:
          _needsSpecialist ? _specialistController.text : null,
      clearSpecialist: !_needsSpecialist,
    );

    Navigator.pop(context); // Close update dialog
    showSynapseSignal(context); // Show signal animation
  }

  @override
  Widget build(BuildContext context) {
    final previewStatus = _previewStatus();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          AppColors.twilightPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note,
                        color: AppColors.twilightPurple, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Hospital Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nightIndigo,
                          ),
                        ),
                        Text(
                          widget.hospital.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.midnightBlue
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: previewStatus.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: previewStatus.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(previewStatus.icon,
                        color: previewStatus.color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Preview',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.midnightBlue
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            previewStatus.label,
                            style: TextStyle(
                              color: previewStatus.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: previewStatus.color,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Staff & Patients row
              const Text(
                'Staffing & Patients',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.nightIndigo,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _staffController,
                      'Active Staff',
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _patientsController,
                      'Patients',
                      Icons.personal_injury,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Beds & Rooms row
              const Text(
                'Bed & Room Availability',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.nightIndigo,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _bedsController,
                      'Beds',
                      Icons.bed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _roomsController,
                      'Rooms',
                      Icons.meeting_room,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Specialist toggle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lavenderHaze.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: _needsSpecialist
                              ? AppColors.pinPink
                              : AppColors.midnightBlue
                                  .withValues(alpha: 0.4),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Needs Specialist',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.nightIndigo,
                            ),
                          ),
                        ),
                        Switch(
                          value: _needsSpecialist,
                          onChanged: (v) =>
                              setState(() => _needsSpecialist = v),
                          activeTrackColor: AppColors.pinPink.withValues(alpha: 0.5),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppColors.pinPink
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (_needsSpecialist) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _specialistController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'e.g., Invasive Pediatric Cardiologist',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.midnightBlue
                                .withValues(alpha: 0.4),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitUpdate,
                  icon: const Icon(Icons.cell_tower, size: 20),
                  label: const Text(
                    'Send Status Update',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon:
            Icon(icon, color: AppColors.twilightPurple, size: 18),
        filled: true,
        fillColor: AppColors.lavenderHaze.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.nightIndigo,
      ),
    );
  }
}

/// Show the status update dialog for a hospital.
Future<void> showStatusUpdateDialog(
    BuildContext context, Hospital hospital) {
  return showDialog(
    context: context,
    builder: (ctx) => StatusUpdateDialog(hospital: hospital),
  );
}
