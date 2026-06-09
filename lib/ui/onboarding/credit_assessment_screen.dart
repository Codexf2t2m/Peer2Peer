import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/services/credit_service.dart';
import 'email_verification_screen.dart' show _OnboardingStepIndicator;

/// Step 4 of onboarding: run the credit assessment.
///
/// Shows an animated "analysing" state, then reveals the borrowing limit
/// and risk band from [CreditService.runAssessment]. On completion it
/// marks onboarding_step = 'active' via the complete_credit_assessment RPC
/// and inserts an account_activated notification.
class CreditAssessmentScreen extends ConsumerStatefulWidget {
  const CreditAssessmentScreen({super.key});

  @override
  ConsumerState<CreditAssessmentScreen> createState() =>
      _CreditAssessmentScreenState();
}

class _CreditAssessmentScreenState
    extends ConsumerState<CreditAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  CreditAssessmentResult? _result;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start assessment on mount
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAssessment());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runAssessment() async {
    if (_started) return;
    setState(() => _started = true);

    final controller = ref.read(onboardingControllerProvider.notifier);
    final result = await controller.runCreditAssessment();

    if (!mounted) return;

    _pulseController.stop();
    setState(() => _result = result);
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(onboardingControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OnboardingStepIndicator(currentStep: 3),
              const SizedBox(height: 40),

              if (isLoading || _result == null) ...[
                _buildAnalysingState(),
              ] else ...[
                _buildResultState(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Analysing state ──────────────────────────────────────────────────────

  Widget _buildAnalysingState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Pulsing radar animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final radius in [80.0, 100.0, 120.0])
                    Transform.scale(
                      scale: _pulseAnimation.value *
                          (1 - (radius - 80) / 200),
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0038FF).withValues(
                            alpha: 0.06 * (1 - (radius - 80) / 200),
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
                        const Color(0xFF0038FF).withValues(alpha: 0.8),
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
          const _AnalysingStepsList(),
          const SizedBox(height: 32),
          const Text(
            'This usually takes a few seconds',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ── Result state ─────────────────────────────────────────────────────────

  Widget _buildResultState(CreditAssessmentResult result) {
    final color = _riskColor(result.riskBand);
    final scorePercent = result.creditScore / 1000.0;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF059669), size: 28),
                SizedBox(width: 10),
                Text(
                  'Assessment complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Score ring + band
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _ScoreRingPainter(
                        progress: scorePercent,
                        color: color,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${result.creditScore}',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'out of 1000',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.riskBand,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Borrowing limit card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0038FF),
                    const Color(0xFF0038FF).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your borrowing limit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'P ${result.borrowingLimit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Available for community & direct loans',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info row
            _buildInfoTile(
              icon: Icons.refresh_rounded,
              title: 'Monthly reassessment',
              subtitle: 'Your limit is reviewed every 30 days as your activity grows.',
            ),
            const SizedBox(height: 10),
            _buildInfoTile(
              icon: Icons.notifications_none_outlined,
              title: 'Account activated',
              subtitle: 'A notification has been sent confirming your account is live.',
            ),
            const SizedBox(height: 32),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _goHome,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0038FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Go to home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0038FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String band) => switch (band.toLowerCase()) {
        'excellent' => const Color(0xFF059669),
        'good' => const Color(0xFF0D9488),
        'fair' => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };
}

// ── Animated step list ────────────────────────────────────────────────────────

class _AnalysingStepsList extends StatefulWidget {
  const _AnalysingStepsList();

  @override
  State<_AnalysingStepsList> createState() => _AnalysingStepsListState();
}

class _AnalysingStepsListState extends State<_AnalysingStepsList> {
  int _activeIndex = 0;

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

  void _tick() {
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        if (_activeIndex < _steps.length - 1) _activeIndex++;
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: done
                    ? const Icon(Icons.check_circle,
                        key: ValueKey('done'), color: Color(0xFF059669), size: 20)
                    : active
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Color(0xFF0038FF)),
                          )
                        : const Icon(Icons.circle_outlined,
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
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Score ring painter ────────────────────────────────────────────────────────

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 16) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc (start from top, go clockwise)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}
