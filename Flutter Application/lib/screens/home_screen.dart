// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import '../service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/database.dart';
import 'package:flutter_application_4/screens/camp_screen.dart';
import 'package:flutter_application_4/screens/tip_screen.dart';
import 'package:flutter_application_4/screens/map_screen.dart';
import 'package:flutter_application_4/screens/account_screen.dart';

// ใช้ชุดสีของ Spotify
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class HomeScreen extends StatefulWidget {
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final double totalCost;
  final double enterFee;
  final double tentRental;
  final double house;
  final double campingFee;
  final String message;
  final int? barindex;
  final CampsiteModel? campsite;

  const HomeScreen(
      {super.key,
      required this.auth,
      this.user,
      this.Exp,
      this.totalCost = 0,
      this.enterFee = 0,
      this.tentRental = 0,
      this.house = 0,
      this.campingFee = 0,
      this.message = '',
      this.barindex,
      this.campsite});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Database db = Database.instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.barindex ?? 0;
    print(
        'Exp value received in HomeScreen: ${widget.Exp}'); // พิมพ์ค่า Exp ที่ได้รับ

    Future.delayed(Duration.zero, () async {
      final currentUser = widget.auth.currentUser;
      if (currentUser != null) {
        // ตรวจสอบว่าผู้ใช้ได้เข้าสู่ระบบด้วยวิธีใด
        String email = 'ไม่ระบุตัวตน'; // ค่าเริ่มต้นสำหรับ Anonymous
        if (!currentUser.isAnonymous) {
          email = currentUser.email ?? 'ไม่มีข้อมูลอีเมล';
        }

        // ดึงข้อมูลผู้ใช้จาก Firestore
        final DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();

        String name = 'กดที่รูปโปรไฟล์เพื่อแก้ไขชื่อผู้ใช้'; // ค่าเริ่มต้นสำหรับ name
        double totalCost = 0.0;
        double enterFee = 0.0;
        double tentRental = 0.0;
        double house = 0.0;
        double campingFee = 0.0;
        String campsite = '';
        List<String> tags = [];
        String background = 'images/Autumn-Orange-Background-for-Desktop.jpg';
        String avatar = 'images/new.png';

        if (snapshot.exists) {
          // ถ้ามีข้อมูลใน Firestore ใช้ข้อมูลที่มีอยู่
          final data = snapshot.data() as Map<String, dynamic>;
          name = data['name'] ??
              name; // ถ้ามี name ใน Firestore ให้ใช้ข้อมูลที่มีอยู่
          email = data['email'] ??
              email; // ถ้ามี email ใน Firestore ให้ใช้ข้อมูลที่มีอยู่
          totalCost = data['totalCost'] ?? totalCost;
          enterFee = data['enterFee'] ?? enterFee;
          tentRental = data['tentRental'] ?? tentRental;
          house = data['house'] ?? house;
          campingFee = data['campingFee'] ?? campingFee;
          campsite = data['campsite'] ?? campsite;
          tags = List<String>.from(data['tag'] ?? []);
          background = data['background'] ?? background;
          avatar = data['avatar'] ?? avatar;
        }

        // ตั้งค่าข้อมูลผู้ใช้เบื้องต้น
        UserModel user = UserModel(
            id: currentUser.uid,
            name: name,
            email: email,
            exp: widget.Exp.toString(), // ตรวจสอบ Exp ที่ได้รับมา
            tag: tags,
            campingFee: campingFee,
            campsite: campsite,
            enterFee: enterFee,
            house: house,
            tentRental: tentRental,
            totalCost: totalCost,
            background: background,
            avatar: avatar);

        await db.setUser(user: user);
      } else {
        print('ผู้ใช้ไม่ได้เข้าสู่ระบบ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            CampScreen(
              auth: widget.auth,
              user: widget.user,
              Exp: widget.Exp,
              isAnonymous: widget.auth.currentUser!
                  .isAnonymous, // ตั้งค่า isAnonymous ที่ถูกต้อง
            ),
            const TipScreen(),
            MapScreen(
              campsite: widget.campsite,
              userID: widget.auth.currentUser!.uid,
            ),
            AccountScreen(
              totalCost: widget.totalCost,
              enterFee: widget.enterFee,
              tentRental: widget.tentRental,
              house: widget.house,
              campingFee: widget.campingFee,
              message: widget.message,
              auth: widget.auth,
              user: widget.auth.currentUser!.uid,
              campsite: widget.campsite,
              isAnonymous: widget.auth.currentUser!
                  .isAnonymous, // ตั้งค่า isAnonymous ที่ถูกต้อง
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kSpotifyBackground,
        selectedItemColor: kSpotifyAccent,
        unselectedItemColor: kSpotifyTextSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cabin_sharp),
            label: 'แคมป์',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates_outlined),
            label: 'เกร็ดความรู้',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'แผนที่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
