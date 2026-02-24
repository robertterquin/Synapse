import '../models/hospital.dart';
import '../services/hospital_manager.dart';

class UserProfile {
  final String name;
  final String hospital;
  final String idNumber;
  final String? specialization;
  bool isVerified;
  String? assignedHospital;

  UserProfile({
    required this.name,
    required this.hospital,
    required this.idNumber,
    this.specialization,
    this.isVerified = false,
    this.assignedHospital,
  });

  /// Check if this user is assigned to the given hospital.
  bool isAssignedTo(Hospital h) {
    if (assignedHospital == null || assignedHospital!.isEmpty) return false;
    final query = assignedHospital!.toLowerCase();
    return h.name.toLowerCase() == query ||
        h.name.toLowerCase().contains(query);
  }

  /// Get the Hospital object the user is assigned to, if any.
  Hospital? get assignedHospitalObj {
    if (assignedHospital == null) return null;
    return HospitalManager().findHospitalByName(assignedHospital!);
  }
}
