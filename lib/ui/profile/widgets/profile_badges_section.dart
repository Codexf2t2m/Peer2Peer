
// UC: Earn Badge
//
// Data-driven badges from BadgeModel list.
// Falls back to static placeholders for new users with no badges.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/models/badge_model.dart';

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({
    super.key,
    required this.badges,
  });

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        badges.isEmpty
            ? _StaticBadges()
            : SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: badges.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _BadgeCard(badge: badge);
                  },
                ),
              ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Color(0xFF0038FF),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown for users with no earned badges yet.
class _StaticBadges extends StatelessWidget {
  static const _items = [
    (
      label: 'Verified\nMember',
      color: Color(0xFF0038FF),
      icon: HugeIcons.strokeRoundedUser,
    ),
    (
      label: 'Trusted\nBorrower',
      color: Color(0xFF00BFA5),
      icon: HugeIcons.strokeRoundedHome01,
    ),
    (
      label: 'Top\nRepayer',
      color: Color(0xFFFF8F00),
      icon: HugeIcons.strokeRoundedAward02,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: i < _items.length - 1 ? 12 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        item.color.withValues(alpha: 0.1),
                    child: HugeIcon(
                      icon: item.icon,
                      color: item.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}