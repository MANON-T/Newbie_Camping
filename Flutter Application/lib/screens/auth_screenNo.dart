import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthScreenNo extends StatefulWidget {
  const AuthScreenNo({super.key});

  @override
  _AuthScreenNoState createState() => _AuthScreenNoState();
}

class _AuthScreenNoState extends State<AuthScreenNo> {
  late AuthService auth;
  late Stream<User?> user;
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
          if (snapshot.hasData) {
            return HomeScreen(
              auth: auth,
              Exp: "ไม่มีประสบการณ์",
            );
          }
          return LoginScreen(
            auth: auth,
          );
        });
  }
}
