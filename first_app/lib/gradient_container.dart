import 'package:flutter/material.dart';
import 'dart:ui';

/// Provides an animated, "modern" gradient background behind the app content.
class GradientContainer extends StatefulWidget {

  const GradientContainer({
    super.key,
    required this.colors,
    required this.child,
  });

  final List<Color> colors;
  final Widget child;

  @override
  State<GradientContainer> createState() => _GradientContainerState();
}

class _GradientContainerState extends State<GradientContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final a = widget.colors;
    final c0 = a.first;
    final c1 = a.length > 1 ? a[1] : a.first;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // Subtle movement across the screen for a more "alive" feel.
        final begin = Alignment.lerp(
          const Alignment(-0.95, -0.95),
          const Alignment(0.95, -0.95),
          t,
        )!;
        final end = Alignment.lerp(
          const Alignment(0.95, 0.95),
          const Alignment(-0.95, 0.95),
          t,
        )!;

        final animatedColors = <Color>[
          Color.lerp(c0, c1, t) ?? c0,
          Color.lerp(c1, c0, t) ?? c1,
        ];

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: animatedColors,
                  begin: begin,
                  end: end,
                ),
              ),
            ),
            // Soft highlight "glass" layer.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      radius: 0.85,
                      center: Alignment.lerp(
                          const Alignment(-0.4, -0.6),
                          const Alignment(0.4, 0.3),
                          t,
                        )!,
                    ),
                  ),
                ),
              ),
            ),
            // Slight blur pass to reduce harsh banding on low-end displays.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
