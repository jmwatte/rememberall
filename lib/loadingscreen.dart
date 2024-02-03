import 'dart:math';

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String displayString;

  const LoadingScreen(this.displayString, {super.key});

  @override
  Widget build(BuildContext context) {
    var displayStringShort =
        displayString.substring(0, min(displayString.length, 40));
    double fontSize = 200.0 - (displayStringShort.length * 5.0);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue,
      child: Center(
        child: Text(
          displayStringShort,
          style: TextStyle(
              fontSize: fontSize == 0 ? 1 : fontSize, color: Colors.white),
        ),
      ),
    );
  }
}
