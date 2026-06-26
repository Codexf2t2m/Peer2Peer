
// The pulsing radar "analysing" state.
// Extracted from _buildAnalysingState() — now a StatefulWidget that
// owns its own AnimationController instead of sharing one with the screen.

import 'package:flutter/material.dart';

import 'analysing_steps_list.dart';

class CreditAnalysingView extends StatefulWidget {
  const CreditAnalysingView({super.key});

  @override
  State<CreditAnalysingView> createState() =>
      _CreditAnalysingViewState();
}

class _CreditAnalysingViewState
    extends State<CreditAnalysingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final radius in [
                    80.0,
                    100.0,
                    120.0
                  ])
                    Transform.scale(
                      scale: _pulseAnimation.value *
                          (1 - (radius - 80) / 200),
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0038FF)
                              .withValues(
                            alpha: 0.06 *
                                (1 - (radius - 80) / 200),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xFF0038FF),
                        const Color(0xFF0038FF)
                            .withValues(alpha: 0.8),
                      ]),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'Analysing your finances',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          const AnalysingStepsList(),
          const SizedBox(height: 32),
          const Text(
            'This usually takes a few seconds',
            style: TextStyle(
                fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}