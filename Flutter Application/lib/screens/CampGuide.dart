import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/CampMate.dart';

class CampGuide extends StatelessWidget {
  const CampGuide({super.key});

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
                  "images/moon.png",
                  width: 300,
                  height: 300,
                ),
              ),
              const Text(
                'แนะนำสถานที่ตั้งแคมป์',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim'),
              ),
              const Text("สถานที่โปรด สถานที่ดีๆ ที่เหมาะกับคุณ",
                  style: TextStyle(fontSize: 17, fontFamily: 'Itim'))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CampMate()),
            );
          },
          child: const Icon(Icons.arrow_forward),
        ));
  }
}
