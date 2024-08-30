import 'package:cloud_firestore/cloud_firestore.dart';

class MedalModel {
  String name;
  String lock;
  String unlock;
  List<String> user;

  MedalModel({
    required this.name,
    required this.lock,
    required this.unlock,
    required this.user,
  });

  // Convert a MedalModel object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lock': lock,
      'unlock': unlock,
      'user': user,
    };
  }

  // Convert a Map object into a MedalModel object
  factory MedalModel.fromMap(Map<String, dynamic> map) {
    return MedalModel(
      name: map['name'] ?? '',
      lock: map['lock'] ?? '',
      unlock: map['unlock'] ?? '',
      user: List<String>.from(map['user'] ?? []),
    );
  }

  // Convert a Firestore DocumentSnapshot into a MedalModel object
  factory MedalModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return MedalModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
