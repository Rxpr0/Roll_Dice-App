import 'package:flutter/material.dart';
import 'package:first_app/gradient_container.dart';
void main() {
  runApp(
     MaterialApp(
      home: Scaffold(
        body: GradientContainer(colors: [const Color.fromARGB(255, 175, 178, 182), const Color.fromARGB(255, 7, 89, 95)]),
      ),
    ),
  );
}

