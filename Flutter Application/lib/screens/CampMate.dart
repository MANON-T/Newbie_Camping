import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/CampRewards.dart';

class CampMate extends StatelessWidget {
  const CampMate({super.key});

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
                  "images/money-management.png",
                  width: 300,
                  height: 300,
                ),
              ),
              const Text(
                "คำนวณค่าใช้จ่าย",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim'),
              ),
              const Text(
                "สะดวก ง่ายดาย ไม่ต้องเสียเวลาคำนวณเอง",
                style: TextStyle(fontFamily: 'Itim', fontSize: 17),
              )
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
              FloatingActionButton(
                heroTag: "forward",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CampRewards()),
                  );
                },
                child: const Icon(Icons.arrow_forward),
              )
            ],
          ),
        ));
  }
}
