import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // @override
  // void initState() {
  //   super.initState();
  //   // ตั้งค่าแถบสถานะเป็นสีขาว เมื่อเข้าไปที่หน้าจอ
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent, // ทำให้แถบสถานะโปร่งใส
  //     // statusBarIconBrightness: Brightness.light, // ตั้งค่าไอคอนเป็นสีขาว
  //   ));
  // }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await _auth.sendPasswordResetEmail(email: _emailController.text);
    
    // แสดง Modal Bottom Sheet เมื่อส่งอีเมลสำเร็จ
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ให้แผงล่างครอบคลุมเต็มจอ
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_chat_unread, // ไอคอนที่คล้ายในภาพ
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              const Text(
                'ตรวจสอบอีเมลของคุณ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Itim'
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'เราได้ส่งคำแนะนำในการกู้คืนรหัสผ่านไปยังอีเมลของคุณแล้ว',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Itim'
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Bottom Sheet
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'เสร็จสิ้น',
                  style: TextStyle(color: Colors.white, fontSize: 16 , fontFamily: 'Itim'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
    
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = _translateErrorToThai(e.code);
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  String _translateErrorToThai(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'อีเมลไม่ถูกต้อง';
      case 'user-not-found':
        return 'ไม่พบผู้ใช้ที่มีอีเมลนี้';
      case 'user-disabled':
        return 'บัญชีนี้ถูกปิดใช้งาน';
      case 'too-many-requests':
        return 'คุณทำการร้องขอมากเกินไป กรุณาลองใหม่ภายหลัง';
      default:
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // backgroundColor: Colors.black,
        title: const Text(
          'ลืมรหัสผ่าน',
          style: TextStyle(fontFamily: 'Itim'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'กรอกอีเมลเพื่อรับลิงก์สำหรับรีเซ็ตรหัสผ่าน',
                  style: TextStyle(fontSize: 17, fontFamily: 'Itim'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _sendPasswordResetEmail,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green),
                        child: const Text(
                          'ดำเนิการต่อ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Itim'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
