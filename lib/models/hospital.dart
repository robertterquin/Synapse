import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum HospitalStatus {
  normal,
  lowBeds,
  patientSurge,
  needStaff,
  patientSurgeNeedStaffLowBeds,
  needSpecialized,
}

enum HospitalType {
  general,
  specialized,
}

extension HospitalStatusExtension on HospitalStatus {
  String get label {
    switch (this) {
      case HospitalStatus.normal:
        return 'Normal Status';
      case HospitalStatus.lowBeds:
        return 'Low Bed & Room Availability';
      case HospitalStatus.patientSurge:
        return 'Patient Surge';
      case HospitalStatus.needStaff:
        return 'In Need of Staff';
      case HospitalStatus.patientSurgeNeedStaffLowBeds:
        return 'Patient Surge • Need Staff • Low Beds';
      case HospitalStatus.needSpecialized:
        return 'In Need of Specialized Doctors';
    }
  }

  Color get color {
    switch (this) {
      case HospitalStatus.normal:
        return AppColors.pinGreen;
      case HospitalStatus.lowBeds:
        return AppColors.pinYellow;
      case HospitalStatus.patientSurge:
        return AppColors.pinOrange;
      case HospitalStatus.needStaff:
        return AppColors.pinBlue;
      case HospitalStatus.patientSurgeNeedStaffLowBeds:
        return AppColors.pinRed;
      case HospitalStatus.needSpecialized:
        return AppColors.pinPink;
    }
  }

  IconData get icon {
    switch (this) {
      case HospitalStatus.normal:
        return Icons.check_circle;
      case HospitalStatus.lowBeds:
        return Icons.bed;
      case HospitalStatus.patientSurge:
        return Icons.groups;
      case HospitalStatus.needStaff:
        return Icons.person_search;
      case HospitalStatus.patientSurgeNeedStaffLowBeds:
        return Icons.warning_amber;
      case HospitalStatus.needSpecialized:
        return Icons.medical_services;
    }
  }
}

class Hospital {
  final String name;
  final HospitalType type;
  final double latitude;
  final double longitude;
  int staff;
  int patients;
  int availableBeds;
  int availableRooms;
  String? specialistNeeded;
  double? compensation;
  String? nearestReferral;

  Hospital({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.staff,
    required this.patients,
    required this.availableBeds,
    required this.availableRooms,
    this.specialistNeeded,
    this.compensation,
    this.nearestReferral,
  });

  /// Auto-classify hospital status based on current statistics.
  ///
  /// Classification rules (checked in priority order):
  /// 🌸 Pink — specialist needed (set manually)
  /// 🔴 Red — staff ratio >= 1:15 AND beds+rooms < 20
  /// 🟠 Orange — patient surge (ratio >= 1:20)
  /// 🔵 Blue — in need of staff (ratio >= 1:15)
  /// 🟡 Yellow — low beds (beds+rooms < 20)
  /// 🟢 Green — normal operations
  HospitalStatus get status {
    final double ratio = staff > 0 ? patients / staff : 0;
    final int totalBeds = availableBeds + availableRooms;

    // 🌸 Pink — specialist needed (manual flag)
    if (specialistNeeded != null && specialistNeeded!.isNotEmpty) {
      return HospitalStatus.needSpecialized;
    }

    // 🔴 Red — staff shortage + low beds (compound crisis)
    if (ratio >= 15 && totalBeds < 20) {
      return HospitalStatus.patientSurgeNeedStaffLowBeds;
    }

    // 🟠 Orange — patient surge (ratio >= 1:20)
    if (ratio >= 20) {
      return HospitalStatus.patientSurge;
    }

    // 🔵 Blue — in need of staff (ratio >= 1:15)
    if (ratio >= 15) {
      return HospitalStatus.needStaff;
    }

    // 🟡 Yellow — low bed/room availability
    if (totalBeds < 20) {
      return HospitalStatus.lowBeds;
    }

    // 🟢 Green — normal status
    return HospitalStatus.normal;
  }

  double get staffToPatientRatio => staff > 0 ? patients / staff : 0;
  String get ratioDisplay =>
      staff > 0 ? '1:${(patients / staff).toStringAsFixed(0)}' : 'N/A';

  bool get isGeneral => type == HospitalType.general;
  bool get isSpecialized => type == HospitalType.specialized;

  bool get needsStaff =>
      status == HospitalStatus.needStaff ||
      status == HospitalStatus.patientSurgeNeedStaffLowBeds;

  bool get hasLowBeds =>
      status == HospitalStatus.lowBeds ||
      status == HospitalStatus.patientSurgeNeedStaffLowBeds;

  bool get hasPatientSurge =>
      status == HospitalStatus.patientSurge ||
      status == HospitalStatus.patientSurgeNeedStaffLowBeds;
}
