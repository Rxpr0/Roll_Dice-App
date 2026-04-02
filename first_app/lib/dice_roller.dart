import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final randomizer = Random();

// Create a single instance of Random to be used throughout the app.
class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  int currentDiceRoll = 2;
  final List<int> _history = [];
  int _totalRolls = 0;
  bool _isRolling = false;
  Timer? _rollTimer;

  void rollDice() {
    if (_isRolling) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isRolling = true;
    });

    const tickEvery = Duration(milliseconds: 70);
    const rollingFor = Duration(milliseconds: 450);

    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(tickEvery, (_) {
      setState(() {
        currentDiceRoll = randomizer.nextInt(6) + 1;
      });
    });

    Future<void>.delayed(rollingFor).then((_) {
      if (!mounted) return;

      _rollTimer?.cancel();

      final finalRoll = randomizer.nextInt(6) + 1;
      setState(() {
        currentDiceRoll = finalRoll;
        _totalRolls++;
        _history.insert(0, finalRoll);
        if (_history.length > 10) _history.removeLast();
        _isRolling = false;
      });

      HapticFeedback.mediumImpact();
    });
  }

  void reset() {
    if (_isRolling) return;
    setState(() {
      _history.clear();
      _totalRolls = 0;
      currentDiceRoll = 1;
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diceWidth = MediaQuery.sizeOf(context).width < 380 ? 150.0 : 200.0;

    final diceFace = AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
            child: RotationTransition(
              turns: Tween<double>(begin: -0.12, end: 0).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/images/dice-$currentDiceRoll.png',
        key: ValueKey<int>(currentDiceRoll),
        width: diceWidth,
        semanticLabel: 'Dice face $currentDiceRoll',
      ),
    );

    return Center(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dice Roller',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildStatPill(label: 'Rolls', value: '$_totalRolls'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    diceFace,
                    const SizedBox(height: 14),
                    Text(
                      _isRolling ? 'Rolling…' : 'Ready',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: rollDice,
                            icon: const Icon(Icons.casino_outlined),
                            label: Text(_isRolling ? 'Rolling' : 'Roll Dice'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.92),
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: _history.isEmpty ? null : reset,
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Reset',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.16),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withOpacity(0.08),
                            disabledForegroundColor: Colors.white30,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Last 10 rolls',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHistory(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistory(ThemeData theme) {
    if (_history.isEmpty) {
      return Text(
        'Press Roll Dice to get started.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.75),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _history.map((value) {
        return Chip(
          label: Text(
            '$value',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.14),
          side: BorderSide(color: Colors.white.withOpacity(0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatPill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
