
// Extracted unchanged — self-contained animation timer.
// Purely cosmetic; does not reflect real backend progress.

import 'package:flutter/material.dart';

class AnalysingStepsList extends StatefulWidget {
  const AnalysingStepsList({super.key});

  @override
  State<AnalysingStepsList> createState() =>
      _AnalysingStepsListState();
}

class _AnalysingStepsListState
    extends State<AnalysingStepsList> {
  int _activeIndex = 0;
  bool _disposed = false;

  static const _steps = [
    'Reading transaction history',
    'Analysing repayment patterns',
    'Checking income regularity',
    'Computing risk profile',
    'Setting borrowing limit',
  ];

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _tick() {
    Future<void>.delayed(
        const Duration(milliseconds: 600), () {
      if (_disposed || !mounted) return;
      setState(() {
        if (_activeIndex < _steps.length - 1) {
          _activeIndex++;
        }
      });
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_steps.length, (i) {
        final done = i < _activeIndex;
        final active = i == _activeIndex;

        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 300),
                child: done
                    ? const Icon(Icons.check_circle,
                        key: ValueKey('done'),
                        color: Color(0xFF059669),
                        size: 20)
                    : active
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0038FF),
                            ),
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            key: ValueKey('pending'),
                            color: Color(0xFFD1D5DB),
                            size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                _steps[i],
                style: TextStyle(
                  fontSize: 14,
                  color: done
                      ? const Color(0xFF059669)
                      : active
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF9CA3AF),
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}