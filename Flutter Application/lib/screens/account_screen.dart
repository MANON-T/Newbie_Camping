import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter_application_4/screens/CampGuide.dart';
import 'package:flutter_application_4/Widgets/backpack.dart';
import 'package:flutter_application_4/Widgets/budget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/screens/StampBookPage.dart';

const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class AccountScreen extends StatefulWidget {
  final double totalCost;
  final double enterFee;
  final double tentRental;
  final double house;
  final double campingFee;
  final String message;
  final AuthService auth;
  final String user;
  final bool isAnonymous;
  final CampsiteModel? campsite;

  const AccountScreen(
      {super.key,
      required this.totalCost,
      required this.enterFee,
      required this.tentRental,
      required this.house,
      required this.campingFee,
      required this.message,
      required this.auth,
      required this.user,
      required this.isAnonymous,
      required this.campsite});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<String> selectedTags = [];
  final List<Map<String, String>> tagOptions = [
    {
      'tag': '#CampLover',
      'description': 'สำหรับผู้ที่หลงใหลในการตั้งแคมป์เป็นชีวิตจิตใจ'
    },
    {
      'tag': '#NatureExplorer',
      'description': 'สำหรับผู้ที่ชอบสำรวจธรรมชาติและสถานที่ใหม่ๆ'
    },
    {'tag': '#WildCook', 'description': 'สำหรับผู้ที่ชอบทำอาหารกลางแจ้ง'},
    {
      'tag': '#MountainClimber',
      'description': 'สำหรับผู้ที่ชอบปีนเขาและตั้งแคมป์บนภูเขา'
    },
    {'tag': '#BeachCamper', 'description': 'สำหรับผู้ที่ชอบตั้งแคมป์ที่ชายหาด'},
    {'tag': '#SoloCamper', 'description': 'สำหรับผู้ที่ชอบการตั้งแคมป์คนเดียว'},
    {
      'tag': '#FamilyCamper',
      'description': 'สำหรับผู้ที่ชอบตั้งแคมป์กับครอบครัว'
    },
    {
      'tag': '#EcoFriendlyCamper',
      'description':
          'สำหรับผู้ที่ใส่ใจเรื่องสิ่งแวดล้อมและการตั้งแคมป์แบบรักษ์โลก'
    },
  ];

  String _selectedImage = 'images/Autumn-Orange-Background-for-Desktop.jpg';
  String _selectedAvatar = 'images/new.png';
  late TextEditingController nameController;
  String? _username;

  Future<void> saveBackground(String background) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({'background': background});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบผู้ใช้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveavatar(String avatar) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({'avatar': avatar});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบผู้ใช้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadavatar() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        String? background = doc.get('avatar') as String?;
        setState(() {
          _selectedAvatar = background != null && background.isNotEmpty
              ? background
              : 'images/new.png';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบผู้ใช้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('เกิดข้อผิดพลาดในการดึงข้อมูล: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  Future<void> _loadBackground() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        String? background = doc.get('background') as String?;
        String? username = doc.get('name') as String?;
        setState(() {
          _selectedImage = background != null && background.isNotEmpty
              ? background
              : 'images/Autumn-Orange-Background-for-Desktop.jpg';
          _username = username != null && username.isNotEmpty
              ? username
              : 'กดที่รูปโปรไฟล์เพื่อแก้ไขชื่อผู้ใช้';
        });
        nameController = TextEditingController(text: _username);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบผู้ใช้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('เกิดข้อผิดพลาดในการดึงข้อมูล: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadavatar();
    _loadTags();
    _loadBackground();
    nameController =
        TextEditingController(text: 'กดที่รูปโปรไฟล์เพื่อแก้ไขชื่อผู้ใช้');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _updateName(String newName) async {
    if (newName.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.user) // ใส่ user id ที่คุณต้องการอัปเดต
          .update({'name': newName});
    }
  }

  Widget _buildNameField() {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'ชื่อผู้ใช้ใหม่',
        labelStyle:
            TextStyle(color: Colors.black, fontFamily: 'Itim', fontSize: 25),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kSpotifyAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kSpotifyAccent),
        ),
      ),
      style: const TextStyle(
          color: Colors.black, fontFamily: 'Itim', fontSize: 17),
    );
  }

  void _loadTags() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.user)
          .get();
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('tag')) {
          setState(() {
            selectedTags = List<String>.from(userData['tag']);
          });
        }
      }
    } catch (e) {
      print("Failed to load tags: $e");
    }
  }

  void _showTagSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'เลือกแท็กที่เข้ากับคุณเพื่อให้ระบบสามารถแนะนำข้อมูลที่คุณสนใจได้มากขึ้น',
                style: TextStyle(fontFamily: 'Itim', fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tagOptions.map((tagOption) {
                    bool isSelected = selectedTags.contains(tagOption['tag']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTags.remove(tagOption['tag']);
                          } else if (selectedTags.length < 3) {
                            if (tagOption['tag'] != null) {
                              selectedTags
                                  .add(tagOption['tag']!); // Add non-null tag
                            }
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.blue,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tagOption['tag']!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Itim'),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  tagOption['description']!,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16.0,
                                      fontFamily: 'Itim'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                Text(
                  '${selectedTags.length}/3',
                  style: const TextStyle(fontFamily: 'Itim', fontSize: 17),
                ),
                TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(widget.user)
                        .update({'tag': selectedTags}).then((_) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print("Failed to update tags: $error");
                    });
                  },
                  child: const Text(
                    'ยืนยัน',
                    style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editAP() async {
    final selectedAvatar = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'แก้ไขรูปโปรไฟล์',
              style: TextStyle(fontFamily: 'Itim', fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 90,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildImageAvatar('images/new.png'),
                            const SizedBox(width: 8),
                            _buildImageAvatar('images/cat.png'),
                            const SizedBox(width: 8),
                            _buildImageAvatar('images/cat_1.png'),
                            const SizedBox(width: 8),
                            _buildImageAvatar('images/dog.png'),
                            const SizedBox(width: 8),
                            _buildImageAvatar('images/panda.png'),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildNameField(),
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateName(nameController.text.trim());
                      Navigator.pop(context, _selectedAvatar);
                    },
                    child: const Text(
                      'ยืนยัน',
                      style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                    ),
                  ),
                )
              ],
            ),
          );
        });

    if (selectedAvatar != null) {
      setState(() {
        _selectedAvatar = selectedAvatar;
        saveavatar(selectedAvatar);
      });
    }
  }

  Widget _buildImageAvatar(String imagePath) {
    bool isSelected = _selectedAvatar == imagePath;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = imagePath;
        });
      },
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            height: 70,
            fit: BoxFit.cover,
          ),
          if (isSelected)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editBT() async {
    final selectedImage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'แก้ไขภาพพื้นหลัง',
            style: TextStyle(fontFamily: 'Itim', fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildImageTile(
                            'images/Autumn-Orange-Background-for-Desktop.jpg',
                          ),
                          const SizedBox(width: 8),
                          _buildImageTile(
                            'images/OIG4.jpeg',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedImage);
                      },
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // ใช้เพื่อเพิ่มระยะห่างระหว่างปุ่ม
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showTagSelectionDialog();
                      },
                      child: const Text(
                        'แก้ไขแท็ก',
                        style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
        saveBackground(selectedImage);
      });
    }
  }

  Widget _buildImageTile(String imagePath) {
    bool isSelected = _selectedImage == imagePath;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = imagePath;
        });
      },
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            height: 200,
            fit: BoxFit.cover,
          ),
          if (isSelected)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpotifyBackground,
      appBar: AppBar(
        backgroundColor: kSpotifyBackground,
        title: const Text(
          '🧾 โปรไฟล์ของคุณ',
          style: TextStyle(
              color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 28,
            ),
            onSelected: (String result) async {
              if (result == 'logout') {
                await widget.auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CampGuide()),
                  (route) => false,
                );
              } else if (result == 'stampbook') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Stampbookpage(
                      userID: widget.user,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (!widget.isAnonymous)
                const PopupMenuItem<String>(
                  value: 'stampbook',
                  child: Row(
                    children: [
                      Icon(Icons.book, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        'สมุดตราปั้ม',
                        style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                      ),
                    ],
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'ออกจากระบบ',
                      style: TextStyle(fontFamily: 'Itim', fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.isAnonymous
            ? _buildAnonymousCard(context)
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(widget.user)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Error loading user data',
                      style: TextStyle(color: kSpotifyTextSecondary),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.green,
                    ));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text(
                      'No user data found',
                      style: TextStyle(color: kSpotifyTextSecondary),
                    );
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var userName = userData['name'] ?? 'ไม่พบชื่อผู้ใช้';
                  var userTags = List<String>.from(userData['tag'] ?? []);

                  return ListView(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Stack(
                        clipBehavior:
                            Clip.none, // ปรับ clipBehavior เป็น Clip.none
                        children: [
                          Container(
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(8.0),
                              constraints: const BoxConstraints(
                                  minWidth: 0, maxWidth: double.infinity),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(_selectedImage),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: GestureDetector(
                              onTap: _editBT,
                              child: const Icon(
                                Icons.edit, // ใช้ไอคอนปากกา
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -25, // ปรับตำแหน่งจากด้านล่างขึ้นมา
                            left: 0,
                            right: 0,
                            child: _buildUserCard(userName, userTags),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(
                            minWidth: 0, maxWidth: double.infinity),
                        decoration: BoxDecoration(
                          color: kSpotifyAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'สัมภาระของฉัน',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: 'Itim'),
                        ),
                      ),
                      Backpack(
                        campsite: widget.campsite,
                        backType: widget.message,
                        id: widget.user,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(
                            minWidth: 0, maxWidth: double.infinity),
                        decoration: BoxDecoration(
                          color: kSpotifyAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'ค่าใช้จ่ายทริปนี้',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: 'Itim'),
                        ),
                      ),
                      Budget(
                        auth: widget.auth,
                        user: widget.user,
                        campsite: widget.campsite,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }),
      ),
    );
  }

  Widget _buildUserCard(String userName, List<String> userTags) {
    return Card(
      color: kSpotifyHighlight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: GestureDetector(
              onTap: _editAP, // เรียกใช้ฟังก์ชันเมื่อกดที่รูปภาพ
              child: Image.asset(
                _selectedAvatar,
                // color: kSpotifyTextPrimary,
                width: 50,
                height: 50,
              ),
            ),
            title: Text(
              'ชื่อผู้ใช้: $userName',
              style: const TextStyle(
                  color: kSpotifyTextPrimary, fontFamily: 'Itim', fontSize: 17),
            ),
            subtitle: userTags.isEmpty
                ? const Text(
                    'กดที่รูปปากกาบนขวาเพื่อเลือกแท็ก',
                    style: TextStyle(
                        color: Colors.red, fontSize: 16.0, fontFamily: 'Itim'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: userTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: kSpotifyAccent,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontFamily: 'Itim'),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'กดที่รูปปากกาบนขวาแก้ไขแท็ก',
                        style: TextStyle(
                          color: kSpotifyAccent,
                          fontSize: 16.0,
                          fontFamily: 'Itim',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousCard(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _showAnonymousWarning(context);
            },
            child: Card(
              color: kSpotifyHighlight.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: kSpotifyAccent),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Anonymous User',
                      style: TextStyle(
                          color: kSpotifyTextPrimary,
                          fontSize: 20.0,
                          // fontWeight: FontWeight.bold,
                          fontFamily: 'Itim'),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'กรุณาลงชื่อเข้าใช้เพื่อเข้าถึงข้อมูลโปรไฟล์',
                      style: TextStyle(
                          color: kSpotifyTextSecondary,
                          fontSize: 18.0,
                          fontFamily: 'Itim'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAnonymousWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'การเข้าถึงถูกจำกัด',
            style: TextStyle(color: kSpotifyTextPrimary, fontFamily: 'Itim'),
          ),
          content: const Text(
            'ระบบการ์ดชาวแคมป์ให้บริการเฉพาะผู้ที่เข้าสู่ระบบเท่านั้น',
            style: TextStyle(
                color: kSpotifyTextSecondary, fontFamily: 'Itim', fontSize: 17),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      color: kSpotifyAccent, fontFamily: 'Itim', fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: kSpotifyBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: kSpotifyAccent),
          ),
        );
      },
    );
  }
}
