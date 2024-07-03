import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/imgs/appIcon.png"),
                radius: 50,
              ),
              Text("SCOLAB"),
            ],
          ),
        ),
      ),
    ),
  );
}
