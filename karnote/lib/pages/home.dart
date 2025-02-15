import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      
      child: Container(
        color: Color(0xff353e43),
        child: Column(
          children: [
            Expanded(child: Container())
          ],
        )
      )
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xff1b1f22)
        ),
        child: Column(
          children: [
            Text('Right Side')
          ]
      ),
      ),
    );
  }
}

