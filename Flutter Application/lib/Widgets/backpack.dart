import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/models/campsite_model.dart';

// ใช้ชุดสีของ Spotify
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class Backpack extends StatefulWidget {
  final CampsiteModel? campsite;
  final String backType;
  final String id;

  const Backpack({
    super.key,
    required this.campsite,
    required this.backType,
    required this.id,
  });

  @override
  State<Backpack> createState() => _BackpackState();
}

class _BackpackState extends State<Backpack> {
  String backpackStatus = "กำลังโหลด...";
  String campsiteName = "กำลังโหลด...";
  List<String> backpackItems = [];

  @override
  void initState() {
    super.initState();
    _loadBackpackStatus();
  }

  Future<void> _loadBackpackStatus() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(widget.id)
              .get();

      String backpack = userSnapshot.data()?['backpack'] ?? '';
      String campsite = userSnapshot.data()?['campsite'] ?? '';

      if (backpack.isEmpty) {
        setState(() {
          backpackStatus = "ยังไม่ได้จัดสัมภาระ";
          backpackItems = ["ยังไม่ได้จัดสัมภาระ"];
        });
      } else {
        setState(() {
          backpackStatus = backpack;
          campsiteName = campsite;
        });
        await _loadBackpackItems(campsite, backpack);
      }
    } catch (e) {
      // setState(() {
      //   backpackStatus = "เกิดข้อผิดพลาดในการโหลดข้อมูล";
      //   backpackItems = ["เกิดข้อผิดพลาดในการโหลดข้อมูล"];
      // });
    }
  }

  Future<void> _loadBackpackItems(
      String campsiteName, String backpackStatus) async {
    try {
      QuerySnapshot<Map<String, dynamic>> campsiteSnapshot =
          await FirebaseFirestore.instance
              .collection('campsite')
              .where('name', isEqualTo: campsiteName)
              .get();

      if (campsiteSnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> campsiteDoc =
            campsiteSnapshot.docs.first;
        Map<String, dynamic> campsiteData = campsiteDoc.data()!;

        List<String> items;
        if (backpackStatus == "สำหรับมือใหม่") {
          items = List<String>.from(campsiteData['newbie_backpack'] ?? []);
        } else if (backpackStatus == "สำหรับทั่วไป แบบ 1") {
          items = List<String>.from(campsiteData['common_backpack1'] ?? []);
        } else if (backpackStatus == "สำหรับทั่วไป แบบ 2") {
          items = List<String>.from(campsiteData['common_backpack2'] ?? []);
        } else {
          items = ["ไม่พบข้อมูลสัมภาระ"];
        }

        setState(() {
          backpackItems = items;
        });
      } else {
        setState(() {
          backpackItems = ["ไม่พบข้อมูลสถานที่ตั้งแคมป์"];
        });
      }
    } catch (e) {
      setState(() {
        backpackItems = ["เกิดข้อผิดพลาดในการโหลดข้อมูล"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: kSpotifyBackground,
          border: Border.all(color: kSpotifyAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                backpackStatus,
                style: const TextStyle(
                    fontSize: 26,
                    // fontWeight: FontWeight.bold,
                    color: kSpotifyTextPrimary,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(height: 16),
              ...backpackItems.map((item) => ListTile(
                    leading:
                        const Icon(Icons.check, color: kSpotifyTextPrimary),
                    title: Text(
                      item,
                      style: const TextStyle(
                          color: kSpotifyTextSecondary,
                          fontFamily: 'Itim',
                          fontSize: 17),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
