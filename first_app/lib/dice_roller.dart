import 'package:flutter/material.dart';
import 'dart:math';

final randomizer = Random(); 
// Create a single instance of Random to be used throughout the app, 
//instead of creating a new instance every time we roll the dice.

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() {
    return _DiceRollerState();
  } 
}

class _DiceRollerState extends State<DiceRoller> {
  var  currentDiceRoll = 2;

  void rollDice() {
    setState(() {
      currentDiceRoll = randomizer.nextInt(6) + 1;
    });
  }

  @override
  Widget build(context) {
    return Column(
              mainAxisSize: MainAxisSize.min, //to center the column vertically
              children: [
                Image.asset(
                  'assets/images/dice-$currentDiceRoll.png',
                   width: 200,
                ),
                const SizedBox(height: 10), // Add some spacing between the image and the button
                TextButton(
                  onPressed: rollDice,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Roll Dice'))
              ],
            );
  }
}