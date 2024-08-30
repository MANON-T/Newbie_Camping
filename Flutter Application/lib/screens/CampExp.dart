import 'package:flutter/material.dart';
import 'package:flutter_application_4/styles/button.dart';
import '../Widgets/NoExp.dart';
import '../Widgets/HaveExp.dart';

class CampExp extends StatelessWidget {
  const CampExp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Image.asset(
                  "images/bag.png",
                  width: 250,
                  height: 250,
                ),
              ),
              const Text(
                "เลือกตัวเลือกประสบการณ์เพื่อให้ระบบรู้จักคุณมากขึ้น",
                style: TextStyle(fontFamily: 'Itim', fontSize: 17),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                style: buttonNoEXP,
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => const NoExp());
                },
                icon: const Icon(
                  Icons.assignment_late,
                  color: Colors.white,
                ),
                label: const Text(
                  "ไม่มีประสบการณ์",
                  style: TextStyle(color: Colors.white, fontFamily: 'Itim'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton.icon(
                style: buttonHaveEXP,
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => const HaveExp());
                },
                icon: const Icon(
                  Icons.assignment_turned_in,
                  color: Colors.white,
                ),
                label: const Text(
                  "มีประสบการณ์",
                  style: TextStyle(color: Colors.white, fontFamily: 'Itim'),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "back",
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              ),
              Expanded(child: Container()),
            ],
          ),
        ));
  }
}
