import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSession.instance,
      builder: (context, _) {
        final email = AppSession.instance.currentEmail;
        final displayName = displayNameFromEmail(email);
        final subtitle = email == null || email.isEmpty
            ? 'Member since Feb 2026 • Gaborone'
            : '$email • Member since Feb 2026';

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              // User info section
              const CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChip('Verified'),
                  const SizedBox(width: 8),
                  _buildChip('4 Cards Connected'),
                ],
              ),
              const SizedBox(height: 32),

              // Progress circle section
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: CircularProgressIndicator(
                          value: 0.69,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF0038FF), // Bright blue
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const Text(
                        '69%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fiar — Top 15% of PulaPay users',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _buildStatCard('12', 'Loans requested'),
                  _buildStatCard('9', 'Fully repaid'),
                  _buildStatCard('6', 'People funded'),
                  _buildStatCard('3', 'Late payments'),
                ],
              ),
              const SizedBox(height: 32),

              // Achievements Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildAchievementBadge(context, 'Verified\nMember', 0)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAchievementBadge(context, 'Trusted\nBorrower', 1)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAchievementBadge(context, 'Top\nRepayer', 2)),
                ],
              ),
              const SizedBox(height: 32),

              // Borrowing Limit
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Borrowing Limit',
                          style: TextStyle(fontSize: 14, color: Color(0xFF1E1E1E), fontWeight: FontWeight.w500),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Next review',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade900, fontWeight: FontWeight.w500),
                            ),
                            const Text(
                              'June 1, 2026',
                              style: TextStyle(fontSize: 12, color: Color(0xFF0038FF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'P 2,330',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Income bracket: P1,000–P5,000/mo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Implicit sign out button to maintain core logic invisibly at the bottom
              TextButton(
                onPressed: () async {
                  await AppSession.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                child: Text('Sign out', style: TextStyle(color: Colors.red.shade300, fontSize: 13)),
              ),
              const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C2C2C),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, String label, int type) {
    bool isLocked = type == 2;

    Widget iconWidget;
    switch (type) {
      case 0:
        iconWidget = Container(
          width: 44,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFbf8957), Color(0xFF81522a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
        );
        break;
      case 1:
        iconWidget = Transform.rotate(
          angle: 3.14159 / 4,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
              ],
            ),
            child: Transform.rotate(
              angle: -3.14159 / 4,
              child: const Icon(Icons.star_border_rounded, color: Colors.white, size: 24),
            ),
          ),
        );
        break;
      case 2:
      default:
        iconWidget = SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: 0.6,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF0038FF),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
        );
        break;
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 48, child: Center(child: iconWidget)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: isLocked ? Colors.grey.shade400 : const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );

    if (isLocked) {
      return CustomPaint(
        painter: DashedRRectPainter(
          color: Colors.grey.shade300,
          strokeWidth: 1.2,
          radius: 20.0,
          dashWidth: 4.0,
          dashSpace: 4.0,
        ),
        child: content,
      );
    }

    return content;
  }
}

class DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.radius = 16.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));

    final pathMetrics = path.computeMetrics();
    final dashPath = Path();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final drawLength = distance + dashWidth < metric.length
            ? dashWidth
            : metric.length - distance;
        dashPath.addPath(
            metric.extractPath(distance, distance + drawLength), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
