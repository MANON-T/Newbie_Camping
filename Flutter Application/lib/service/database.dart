import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter_application_4/models/tip_model.dart';
import 'package:flutter_application_4/models/medal_model.dart';

class Database {
  // static Database instance = Database._();
  // Database._();

  static final Database instance = Database._internal();
  Database._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MedalModel?> getMedalByName(String name) async {
    try {
      // ค้นหาเอกสารใน collection 'medal' โดยใช้ค่า field 'name'
      QuerySnapshot querySnapshot = await _firestore
          .collection('medal')
          .where('name', isEqualTo: name)
          .get();

      // ตรวจสอบว่ามีเอกสารที่ค้นพบหรือไม่
      if (querySnapshot.docs.isNotEmpty) {
        // นำข้อมูลเอกสารแรกที่พบมาแปลงเป็น MedalModel
        DocumentSnapshot doc = querySnapshot.docs.first;
        return MedalModel.fromDocumentSnapshot(doc);
      } else {
        // หากไม่พบเอกสาร ให้คืนค่า null
        return null;
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่อาจเกิดขึ้น
      print('Error fetching medal: $e');
      return null;
    }
  }

  Stream<List<CampsiteModel>> getAllCampsiteStream() {
    final reference = FirebaseFirestore.instance.collection('campsite');
    Query query = reference.orderBy('camp_score', descending: true);
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      return snapshot.docs.map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return CampsiteModel.fromMap(data);
        } else {
          // กรณีที่ไม่มีเอกสารหรือเกิดข้อผิดพลาด
          throw Exception('Document does not exist');
        }
      }).toList();
    });
  }

  Stream<List<MedalModel>> getAllMedalStream() {
    final reference = FirebaseFirestore.instance.collection('medal');
    Query query = reference.orderBy('name', descending: true);
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      return snapshot.docs.map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return MedalModel.fromMap(data);
        } else {
          // กรณีที่ไม่มีเอกสารหรือเกิดข้อผิดพลาด
          throw Exception('Document does not exist');
        }
      }).toList();
    });
  }

  Stream<List<TipModel>> getallTipStream() {
    final reference = FirebaseFirestore.instance.collection('tip');
    Query query = reference.orderBy('timestamp', descending: true);
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      return snapshot.docs.map((doc) {
        // Ensure the data is cast to Map<String, dynamic> before passing to UserModel.fromMap
        final data = doc.data() as Map<String, dynamic>;
        return TipModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> setUser({required UserModel user}) async {
    print(
        'User ID: ${user.id}, Exp to save: ${user.exp}'); // พิมพ์ค่า User ID และ Exp ที่จะบันทึก
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<String> getUser({required String id}) async {
    try {
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.doc('user/$id').get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final name = data['name'] as String;
        return name;
      } else {
        // ในกรณีที่ไม่พบข้อมูลหรือเอกสาร
        return ''; // หรือค่าเริ่มต้นของ exp ที่คุณต้องการ
      }
    } catch (e) {
      // การจัดการข้อผิดพลาด
      print('Error getting exp: $e');
      return ''; // หรือค่าเริ่มต้นของ exp ที่คุณต้องการ
    }
  }

  Future<String> getExp({required String id}) async {
    try {
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.doc('user/$id').get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final exp = data['exp'] as String;
        return exp;
      } else {
        // ในกรณีที่ไม่พบข้อมูลหรือเอกสาร
        return ''; // หรือค่าเริ่มต้นของ exp ที่คุณต้องการ
      }
    } catch (e) {
      // การจัดการข้อผิดพลาด
      print('Error getting exp: $e');
      return ''; // หรือค่าเริ่มต้นของ exp ที่คุณต้องการ
    }
  }

  Future<List<CampsiteModel>> searchCampsitesByName(String searchString) async {
    try {
      // คิวรีสำหรับชื่อที่ขึ้นต้นด้วย searchString
      final startResults = await _firestore
          .collection('campsite')
          .where('name', isGreaterThanOrEqualTo: searchString)
          .where('name', isLessThanOrEqualTo: '$searchString\uf8ff')
          .get();

      // คิวรีสำหรับชื่อที่มี searchString อยู่ในกลางหรือท้าย
      final allResults = await _firestore.collection('campsite').get();
      final filteredResults = allResults.docs.where((doc) {
        final name = doc['name'] as String;
        return name.toLowerCase().contains(searchString.toLowerCase());
      }).toList();

      // ใช้ Set เพื่อเก็บ document ID ที่ไม่ซ้ำกัน
      final uniqueDocumentIds = <String>{};
      final combinedResults = <QueryDocumentSnapshot>[];

      // รวมผลลัพธ์จากการคิวรีทั้งสองครั้งโดยตรวจสอบ document ID ไม่ให้ซ้ำกัน
      for (var doc in startResults.docs) {
        if (uniqueDocumentIds.add(doc.id)) {
          combinedResults.add(doc);
        }
      }
      for (var doc in filteredResults) {
        if (uniqueDocumentIds.add(doc.id)) {
          combinedResults.add(doc);
        }
      }

      // แปลงผลลัพธ์เป็น List<CampsiteModel>
      return combinedResults.map((doc) {
        return CampsiteModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        // จัดการกับข้อผิดพลาดกรณีไม่มีสิทธิ์
        print('Permission denied: ${e.message}');
        throw FirebaseException(
          plugin: 'Firestore',
          code: 'permission-denied',
          message: 'You do not have permission to access this data.',
        );
      } else {
        // จัดการกับข้อผิดพลาดทั่วไป
        print('Error: $e');
        print('StackTrace: $stackTrace');
        throw Exception('Failed to load data.');
      }
    }
  }

  Future<List<CampsiteModel>> getCampsitesByTag(List<String> tags) async {
    try {
      // สร้าง query สำหรับดึงข้อมูลจาก collection 'campsite'
      Query query = _firestore.collection('campsite');
      // เพิ่ม condition สำหรับแต่ละแท็กใน tags
      for (String tag in tags) {
        query = query.where('tag', arrayContains: tag);
      }
      // ดึงข้อมูลจาก query
      QuerySnapshot snapshot = await query.get();
      // แปลงข้อมูลเป็น List<CampsiteModel>
      return snapshot.docs.map((doc) {
        return CampsiteModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // จัดการข้อผิดพลาด
      print('Error getting campsites by tag: $e');
      rethrow;
    }
  }
}
