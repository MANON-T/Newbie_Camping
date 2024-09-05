import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/TagResultsScreen.dart'; // Import your new screen
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/user_model.dart';

class Suggestion extends StatelessWidget {
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;

  const Suggestion({
    super.key,
    required this.auth,
    required this.user,
    required this.Exp,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // กำหนดสีพื้นหลังเป็นสีดำ
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'แนะนำสำหรับคุณ',
            style: TextStyle(
                fontSize: 20.0,
                // fontWeight: FontWeight.bold,
                color: Colors.white, // กำหนดสีตัวหนังสือเป็นสีขาว
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildButtonList(context),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the list of buttons based on the value of Exp
  List<Widget> _buildButtonList(BuildContext context) {
    List<Widget> buttonList = [];

    // Adding all buttons first
    List<Map<String, dynamic>> buttons = [
      {
        'text': 'สำหรับมือใหม่',
        'color': Colors.red.shade200,
        'tag': 'สำหรับมือใหม่'
      },
      {
        'text': 'ค่าจอดรถฟรี',
        'color': Colors.orange.shade200,
        'tag': 'ค่าจอดรถฟรี'
      },
      {
        'text': 'ค่าเข้าเด็กฟรี',
        'color': Colors.yellow.shade200,
        'tag': 'ค่าเข้าเด็กฟรี'
      },
      {
        'text': 'ค่าเข้าผู้ใหญ่ฟรี',
        'color': Colors.green.shade200,
        'tag': 'ค่าเข้าผู้ใหญ่ฟรี'
      },
      {'text': 'มีกิจกรรม', 'color': Colors.cyan.shade200, 'tag': 'มีกิจกรรม'},
      {
        'text': 'มีเต็นท์บริการ',
        'color': Colors.purple.shade200,
        'tag': 'มีเต็นท์บริการ'
      },
      {'text': 'มีที่พัก', 'color': Colors.pink.shade200, 'tag': 'มีที่พัก'},
      {
        'text': 'มีปลั๊กไฟพ่วง',
        'color': Colors.grey.shade200,
        'tag': 'มีปลั๊กไฟพ่วง'
      },
      {
        'text': 'ห้องน้ำสะอาด',
        'color': Colors.indigo.shade200,
        'tag': 'ห้องน้ำสะอาด'
      },
      {
        'text': 'มีสัญญาณค่าย True',
        'color': Colors.lightGreenAccent.shade200,
        'tag': 'มีสัญญาณค่าย True'
      },
      {
        'text': 'มีสัญญาณค่าย Ais',
        'color': Colors.lightBlue.shade200,
        'tag': 'มีสัญญาณค่าย Ais'
      },
      {
        'text': 'มีสัญญาณค่าย Dtac',
        'color': Colors.teal.shade200,
        'tag': 'มีสัญญาณค่าย Dtac'
      },
    ];

    // Filtering buttons based on the value of Exp
    for (var button in buttons) {
      if (Exp == 'ไม่มีประสบการณ์' ||
          (Exp == 'มีประสบการณ์' && button['tag'] != 'สำหรับมือใหม่')) {
        buttonList.add(
          _buildEllipseButton(
            button['text'],
            button['color'],
            button['tag'],
            context,
          ),
        );
        buttonList
            .add(const SizedBox(width: 8.0)); // Adding space between buttons
      }
    }

    return buttonList;
  }

  // Function to build each ellipse button
  Widget _buildEllipseButton(
    String text,
    Color color,
    String tag,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TagResultsScreen(
              tag: tag,
              auth: auth,
              user: user,
              Exp: Exp,
              isAnonymous: isAnonymous,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16.0, color: Colors.black, fontFamily: 'Itim'),
        ),
      ),
    );
  }
}
