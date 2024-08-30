import 'package:cloud_firestore/cloud_firestore.dart';

class CampsiteModel {
  bool accommodationAvailable;
  List<String> activities;
  double adultEntryFee;
  double campscore;
  List<String> campimage;
  double campingFee;
  double childEntryFee;
  bool cleanRestrooms;
  List<String> common_backpack1;
  List<String> common_backpack2;
  bool genderSeparatedRestrooms;
  String imageURL;
  String name;
  List<String> newbie_backpack;
  double parkingFee;
  List<String> phoneSignal;
  bool powerAccess;
  bool tentService;
  List<String> warning;
  List<double> house;
  List<double> tent_rental;
  List<String> tag;
  GeoPoint locationCoordinates; // เพิ่มฟิลด์นี้

  // Constructor
  CampsiteModel({
    required this.accommodationAvailable,
    required this.activities,
    required this.adultEntryFee,
    required this.campscore,
    required this.campimage,
    required this.campingFee,
    required this.childEntryFee,
    required this.cleanRestrooms,
    required this.common_backpack1,
    required this.common_backpack2,
    required this.genderSeparatedRestrooms,
    required this.imageURL,
    required this.name,
    required this.newbie_backpack,
    required this.parkingFee,
    required this.phoneSignal,
    required this.powerAccess,
    required this.tentService,
    required this.warning,
    required this.house,
    required this.tent_rental,
    required this.tag,
    required this.locationCoordinates, // เพิ่มฟิลด์นี้
  });

  // Factory method to create CampsiteModel from a map
  factory CampsiteModel.fromMap(Map<String, dynamic> map) {
    return CampsiteModel(
      accommodationAvailable: map['accommodation_available'] as bool? ?? false,
      activities: (map['activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      adultEntryFee: (map['adult_entry_fee'] as num?)?.toDouble() ?? 0.0,
      campscore: (map['camp_score'] as num?)?.toDouble() ?? 0.0,
      campimage: (map['campimage'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      campingFee: (map['camping_fee'] as num?)?.toDouble() ?? 0.0,
      childEntryFee: (map['child_entry_fee'] as num?)?.toDouble() ?? 0.0,
      cleanRestrooms: map['clean_restrooms'] as bool? ?? false,
      common_backpack1: (map['common_backpack1'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      common_backpack2: (map['common_backpack2'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      genderSeparatedRestrooms:
          map['gender_separated_restrooms'] as bool? ?? false,
      imageURL: map['imageURL'] as String? ?? '',
      name: map['name'] as String? ?? '',
      newbie_backpack: (map['newbie_backpack'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      parkingFee: (map['parking_fee'] as num?)?.toDouble() ?? 0.0,
      phoneSignal: (map['phone_signal'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      powerAccess: map['power_access'] as bool? ?? false,
      tentService: map['tent_service'] as bool? ?? false,
      warning: (map['warning'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      house: (map['House'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList() ??
          [],
      tent_rental: (map['Tent_rental'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList() ??
          [],
      tag: (map['tag'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      locationCoordinates:
          map['location_coordinates'] as GeoPoint, // เพิ่มฟิลด์นี้
    );
  }

  // Factory method to create CampsiteModel from a Firebase document
  factory CampsiteModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampsiteModel.fromMap(data);
  }

  // Method to convert CampsiteModel to a map
  Map<String, dynamic> toMap() {
    return {
      'accommodation_available': accommodationAvailable,
      'activities': activities,
      'adult_entry_fee': adultEntryFee,
      'camp_score': campscore,
      'campimage': campimage,
      'camping_fee': campingFee,
      'child_entry_fee': childEntryFee,
      'clean_restrooms': cleanRestrooms,
      'common_backpack1': common_backpack1,
      'common_backpack2': common_backpack2,
      'gender_separated_restrooms': genderSeparatedRestrooms,
      'imageURL': imageURL,
      'name': name,
      'newbie_backpack': newbie_backpack,
      'parking_fee': parkingFee,
      'phone_signal': phoneSignal,
      'power_access': powerAccess,
      'tent_service': tentService,
      'warning': warning,
      'House': house,
      'Tent_rental': tent_rental,
      'tag': tag,
      'location_coordinates': locationCoordinates, // เพิ่มฟิลด์นี้
    };
  }
}
