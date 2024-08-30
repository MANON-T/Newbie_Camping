import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/CampExp.dart';

class CampRewards extends StatelessWidget {
  const CampRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Image.asset(
                  "images/postcard.png",
                  width: 300,
                  height: 300,
                ),
              ),
              const Text(
                "สะสมความเป็นตัวคุณ",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim'),
              ),
              const Text(
                "ตั้งแคมป์และรับตราปั้มสุดเป็นเอกลักษณ์",
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
                    MaterialPageRoute(builder: (context) => const CampExp()),
                  );
                },
                child: const Icon(Icons.arrow_forward),
              )
            ],
          ),
        ));
  }
}
