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
        'color': Colors.blue.shade200,
        'tag': 'สำหรับมือใหม่'
      },
      {'text': 'ประหยัดงบ', 'color': Colors.green.shade200, 'tag': 'ประหยัดงบ'},
      {
        'text': 'ค่าเข้าฟรี',
        'color': Colors.orange.shade200,
        'tag': 'ค่าเข้าฟรี'
      },
      {
        'text': 'มีเต้นบริการ',
        'color': Colors.purple.shade200,
        'tag': 'มีเต้นบริการ'
      },
      {'text': 'สายลุย', 'color': Colors.red.shade200, 'tag': 'สายลุย'},
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
