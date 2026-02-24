import '../models/hospital.dart';

/// Metro Manila DOH hospitals with statistics that drive auto-classification.
///
/// Status is computed automatically from staff/patient ratio and bed counts:
/// 🌸 Pink — specialistNeeded is set
/// 🔴 Red — ratio >= 1:15 AND beds+rooms < 20
/// 🟠 Orange — ratio >= 1:20 (patient surge)
/// 🔵 Blue — ratio >= 1:15 (need staff)
/// 🟡 Yellow — beds+rooms < 20 (low availability)
/// 🟢 Green — normal operations
final List<Hospital> metroManilaHospitals = [
  // 🔴 Red — ratio=15.83, totalBeds=15
  Hospital(
    name: 'Amang Rodriguez Memorial Medical Center',
    type: HospitalType.general,
    latitude: 14.6042,
    longitude: 121.1013,
    staff: 18,
    patients: 285,
    availableBeds: 12,
    availableRooms: 3,
    compensation: 85000,
    nearestReferral: 'Rizal Medical Center',
  ),

  // 🟢 Green — ratio=11.07, totalBeds=500
  Hospital(
    name: 'East Avenue Medical Center',
    type: HospitalType.general,
    latitude: 14.6425,
    longitude: 121.0444,
    staff: 28,
    patients: 310,
    availableBeds: 450,
    availableRooms: 50,
  ),

  // 🌸 Pink — specialist needed overrides all other rules
  Hospital(
    name: 'Dr. Jose Fabella Memorial Hospital',
    type: HospitalType.specialized,
    latitude: 14.5958,
    longitude: 120.9808,
    staff: 14,
    patients: 180,
    availableBeds: 250,
    availableRooms: 12,
    specialistNeeded: 'Neonatologist',
    compensation: 120000,
  ),

  // 🟡 Yellow — ratio=10, totalBeds=17
  Hospital(
    name: 'Dr. Jose N. Rodriguez Memorial Hospital and Sanitarium',
    type: HospitalType.specialized,
    latitude: 14.7347,
    longitude: 121.1117,
    staff: 22,
    patients: 220,
    availableBeds: 12,
    availableRooms: 5,
    nearestReferral: 'Jose R. Reyes Memorial Medical Center',
  ),

  // 🟢 Green — ratio=12.17, totalBeds=450
  Hospital(
    name: 'Jose R. Reyes Memorial Medical Center',
    type: HospitalType.general,
    latitude: 14.6058,
    longitude: 120.9858,
    staff: 23,
    patients: 280,
    availableBeds: 400,
    availableRooms: 50,
  ),

  // 🟠 Orange — ratio=21.25, totalBeds=175
  Hospital(
    name: 'Las Piñas General Hospital and Satellite Trauma Center',
    type: HospitalType.general,
    latitude: 14.4500,
    longitude: 120.9833,
    staff: 16,
    patients: 340,
    availableBeds: 150,
    availableRooms: 25,
    nearestReferral: 'Quirino Memorial Medical Center',
  ),

  // 🔵 Blue — ratio=15.71, totalBeds=158
  Hospital(
    name: 'National Center for Geriatric Health',
    type: HospitalType.specialized,
    latitude: 14.6408,
    longitude: 121.0419,
    staff: 7,
    patients: 110,
    availableBeds: 140,
    availableRooms: 18,
    compensation: 70000,
  ),

  // 🌸 Pink — specialist needed
  Hospital(
    name: 'National Center for Mental Health',
    type: HospitalType.specialized,
    latitude: 14.6833,
    longitude: 121.1000,
    staff: 30,
    patients: 450,
    availableBeds: 4200,
    availableRooms: 200,
    specialistNeeded: 'Psychiatrist',
    compensation: 95000,
  ),

  // 🌸 Pink — specialist needed
  Hospital(
    name: 'National Children\'s Hospital',
    type: HospitalType.specialized,
    latitude: 14.5792,
    longitude: 120.9844,
    staff: 16,
    patients: 200,
    availableBeds: 300,
    availableRooms: 15,
    specialistNeeded: 'Invasive Pediatric Cardiologist',
    compensation: 150000,
  ),

  // 🟢 Green — ratio=12.86, totalBeds=390
  Hospital(
    name: 'Philippine Cancer Center',
    type: HospitalType.specialized,
    latitude: 14.6417,
    longitude: 121.0439,
    staff: 14,
    patients: 180,
    availableBeds: 350,
    availableRooms: 40,
  ),

  // 🟠 Orange — ratio=20.67, totalBeds=225
  Hospital(
    name: 'Philippine Orthopedic Center',
    type: HospitalType.specialized,
    latitude: 14.6183,
    longitude: 121.0336,
    staff: 15,
    patients: 310,
    availableBeds: 200,
    availableRooms: 25,
    nearestReferral: 'East Avenue Medical Center',
  ),

  // 🟢 Green — ratio=12.22, totalBeds=420
  Hospital(
    name: 'Quirino Memorial Medical Center',
    type: HospitalType.general,
    latitude: 14.5633,
    longitude: 121.0483,
    staff: 18,
    patients: 220,
    availableBeds: 400,
    availableRooms: 20,
  ),

  // 🔵 Blue — ratio=15.83, totalBeds=222
  Hospital(
    name: 'Research Institute for Tropical Medicine',
    type: HospitalType.specialized,
    latitude: 14.4833,
    longitude: 121.0500,
    staff: 6,
    patients: 95,
    availableBeds: 200,
    availableRooms: 22,
    compensation: 80000,
  ),

  // 🟡 Yellow — ratio=12.5, totalBeds=17
  Hospital(
    name: 'Rizal Medical Center',
    type: HospitalType.general,
    latitude: 14.5833,
    longitude: 121.0667,
    staff: 24,
    patients: 300,
    availableBeds: 14,
    availableRooms: 3,
    nearestReferral: 'Quirino Memorial Medical Center',
  ),

  // 🟢 Green — ratio=12.86, totalBeds=368
  Hospital(
    name: 'San Lazaro Hospital',
    type: HospitalType.general,
    latitude: 14.6117,
    longitude: 120.9800,
    staff: 14,
    patients: 180,
    availableBeds: 350,
    availableRooms: 18,
  ),

  // 🔴 Red — ratio=18, totalBeds=10
  Hospital(
    name: 'Senate President Neptali A. Gonzales General Hospital',
    type: HospitalType.general,
    latitude: 14.5667,
    longitude: 121.0333,
    staff: 14,
    patients: 252,
    availableBeds: 8,
    availableRooms: 2,
    compensation: 75000,
    nearestReferral: 'Quirino Memorial Medical Center',
  ),

  // 🔵 Blue — ratio=15.5, totalBeds=210
  Hospital(
    name: 'Tondo Medical Center',
    type: HospitalType.general,
    latitude: 14.6167,
    longitude: 120.9650,
    staff: 10,
    patients: 155,
    availableBeds: 200,
    availableRooms: 10,
    compensation: 65000,
  ),

  // 🟢 Green — ratio=13, totalBeds=265
  Hospital(
    name: 'Valenzuela Medical Center',
    type: HospitalType.general,
    latitude: 14.6917,
    longitude: 120.9667,
    staff: 10,
    patients: 130,
    availableBeds: 250,
    availableRooms: 15,
  ),
];
