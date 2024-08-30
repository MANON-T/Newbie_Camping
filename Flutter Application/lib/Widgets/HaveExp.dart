import 'package:flutter/material.dart';
import 'package:flutter_application_4/styles/button.dart';
import '../screens/auth_screenHave.dart';

class HaveExp extends StatelessWidget {
  const HaveExp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: Colors.white,
        ),
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              // ทำให้ข้อความอยู่ตรงกลาง
              child: Text(
                "แจ้งเตือน",
                style: TextStyle(fontSize: 20, fontFamily: 'Itim'),
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "ระบบจะเสนอข้อมูลที่จำเป็นเท่านั้น",
              style: TextStyle(fontSize: 17, fontFamily: 'Itim'),
            ),
            const Text(
              "และจะตัดรายละเอียดยิบย่อยออก",
              style: TextStyle(fontSize: 17, fontFamily: 'Itim'),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              // จัดให้ปุ่มยืนยันอยู่ตรงกลาง
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AuthScreenHave()),
                  );
                },
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                label: const Text(
                  "ยืนยัน",
                  style: TextStyle(color: Colors.white, fontFamily: 'Itim'),
                ),
                style: buttonaccept,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
