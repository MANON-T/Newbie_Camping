import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_4/screens/auth_screen.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // ทำให้แถบสถานะโปร่งใส
      statusBarIconBrightness: Brightness.dark, // ตั้งค่าไอคอนเป็นสีขาว
      systemNavigationBarColor: Colors.black, // สีของ navigation bar ล่าง
      systemNavigationBarIconBrightness: Brightness.light, // สีไอคอน navigation bar
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
    );
  }
}
