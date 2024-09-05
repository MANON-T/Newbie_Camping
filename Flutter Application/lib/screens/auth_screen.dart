import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/screens/CampGuide.dart';
import '../service/auth_service.dart';
import 'home_screen.dart';
import '../service/database.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthService auth;
  late Stream<User?> user;
  Database db = Database.instance;
  @override
  void initState() {
    super.initState();
    auth = AuthService();
    user = auth.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: user,
        builder: (context, snapshot) {
          final currentUser = snapshot.data;
          if (currentUser != null) {
            // เรียกใช้ getExp และส่งข้อมูลผู้ใช้ไป
            return FutureBuilder<String>(
                future: db.getExp(id: currentUser.uid),
                builder: (context, expSnapshot) {
                  final exp = expSnapshot.data;
                  if (exp != null && exp.isNotEmpty) {
                    return HomeScreen(auth: auth, Exp: exp);
                  } else {
                    return const CampGuide();
                  }
                });
          } else {
            return const CampGuide();
          }
        });
  }
}