import 'package:flutter/foundation.dart';
import '../data/hospitals_data.dart';
import '../models/hospital.dart';

/// Singleton ChangeNotifier that manages hospital state across the app.
/// When any hospital's stats are updated, listeners are notified so
/// the map pins, hospital status list, and profile page all refresh.
class HospitalManager extends ChangeNotifier {
  static final HospitalManager _instance = HospitalManager._();
  factory HospitalManager() => _instance;
  HospitalManager._();

  List<Hospital> get hospitals => metroManilaHospitals;

  /// Find a hospital by exact or partial name match.
  Hospital? findHospitalByName(String name) {
    final query = name.toLowerCase();
    try {
      return hospitals.firstWhere(
        (h) => h.name.toLowerCase() == query,
      );
    } catch (_) {
      // Try partial match
      try {
        return hospitals.firstWhere(
          (h) => h.name.toLowerCase().contains(query),
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Update a hospital's statistics. Status auto-recomputes from the
  /// new values. All listeners (map, status list, profile) are notified.
  void updateHospitalStats({
    required Hospital hospital,
    int? staff,
    int? patients,
    int? availableBeds,
    int? availableRooms,
    String? specialistNeeded,
    bool clearSpecialist = false,
  }) {
    if (staff != null) hospital.staff = staff;
    if (patients != null) hospital.patients = patients;
    if (availableBeds != null) hospital.availableBeds = availableBeds;
    if (availableRooms != null) hospital.availableRooms = availableRooms;
    if (clearSpecialist) {
      hospital.specialistNeeded = null;
    } else if (specialistNeeded != null && specialistNeeded.isNotEmpty) {
      hospital.specialistNeeded = specialistNeeded;
    }
    notifyListeners();
  }

  /// Quick-set: Report the hospital needs a specialist.
  void reportSpecialistNeeded(Hospital hospital, String specialist) {
    hospital.specialistNeeded = specialist;
    notifyListeners();
  }

  /// Quick-set: Clear specialist need (resolved).
  void clearSpecialistNeed(Hospital hospital) {
    hospital.specialistNeeded = null;
    notifyListeners();
  }

  /// Quick-set: Report low bed availability.
  void reportLowBeds(Hospital hospital, int beds, int rooms) {
    hospital.availableBeds = beds;
    hospital.availableRooms = rooms;
    notifyListeners();
  }

  /// Quick-set: Report patient surge.
  void reportPatientSurge(Hospital hospital, int patients) {
    hospital.patients = patients;
    notifyListeners();
  }
}
