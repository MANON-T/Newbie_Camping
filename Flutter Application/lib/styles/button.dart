import 'package:flutter/material.dart';

final ButtonStyle buttonNoEXP = ElevatedButton.styleFrom(
    minimumSize: const Size(327, 50),
    backgroundColor: Colors.green,
    elevation: 0,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50))));

final ButtonStyle buttonHaveEXP = ElevatedButton.styleFrom(
    minimumSize: const Size(327, 50),
    backgroundColor: Colors.black,
    elevation: 0,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50))));

final ButtonStyle buttonaccept = ElevatedButton.styleFrom(
    minimumSize: const Size(327, 50),
    backgroundColor: Colors.blue,
    elevation: 0,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50))));