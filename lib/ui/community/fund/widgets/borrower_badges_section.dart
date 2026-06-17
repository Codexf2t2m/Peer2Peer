
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/models/badge_model.dart';
import 'dashed_rrect_painter.dart';

class BorrowerBadgesSection extends StatelessWidget {
  const BorrowerBadgesSection({super.key, required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verified badges',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: badges.asMap().entries.map((entry) {
              final index = entry.key;
              final badge = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    right: index < badges.length - 1 ? 12 : 0),
                child: _BadgeTile(badge: badge),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: badge.isLocked ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Center(child: _BadgeIcon(badge: badge)),
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: badge.isLocked
                  ? Colors.grey.shade400
                  : const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );

    if (badge.isLocked) {
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

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.badge});
  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    if (badge.isLocked) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: badge.progressToUnlock ?? 0.5,
                strokeWidth: 4,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF0038FF),
                strokeCap: StrokeCap.round,
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedLock,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      );
    }

    final List<Color> colors;
    final List<List<dynamic>> icon;
    final BoxShape shape;

    switch (badge.tier) {
      case BadgeTier.bronze:
        colors = [const Color(0xFFbf8957), const Color(0xFF81522a)];
        icon = HugeIcons.strokeRoundedStar;
        shape = BoxShape.rectangle;
      case BadgeTier.silver:
        colors = [const Color(0xFFB0BEC5), const Color(0xFF78909C)];
        icon = HugeIcons.strokeRoundedStarOff;
        shape = BoxShape.rectangle;
      case BadgeTier.gold:
        colors = [const Color(0xFFFFB74D), const Color(0xFFF57C00)];
        icon = HugeIcons.strokeRoundedStar;
        shape = BoxShape.circle;
      case BadgeTier.platinum:
        colors = [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
        icon = HugeIcons.strokeRoundedStar;
        shape = BoxShape.circle;
    }

    final isSilver = badge.tier == BadgeTier.silver;

    Widget iconWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(12)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSilver
          ? Transform.rotate(
              angle: -3.14159 / 4,
              child:
                  HugeIcon(icon: icon, color: Colors.white, size: 24),
            )
          : HugeIcon(icon: icon, color: Colors.white, size: 26),
    );

    if (isSilver) {
      iconWidget = Transform.rotate(
        angle: 3.14159 / 4,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
