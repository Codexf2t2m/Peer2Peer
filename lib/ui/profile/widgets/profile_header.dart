
import 'package:flutter/material.dart';

import '../../../data/models/user_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundImage:
              NetworkImage(profile.resolvedAvatarUrl),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.subtitleLine,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProfileChip(label: 'Verified'),
            const SizedBox(width: 8),
            _ProfileChip(
              label:
                  'Rep Score ${profile.reputationScore}',
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.grey.shade200, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }
}