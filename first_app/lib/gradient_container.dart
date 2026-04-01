import 'package:first_app/dice_roller.dart';
import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {

 const GradientContainer({super.key, required this.colors});

  final List<Color> colors;

  
  @override
  Widget build(context) {
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:  Center(
            child: DiceRoller()
          ),
     );
  }
}
