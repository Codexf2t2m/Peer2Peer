
// Aggregates everything the ProfileScreen needs:
//   PROFILES         → name, email, avatar, reputation_score
//   CREDIT_PROFILES  → credit score, risk band, borrowing limit
//   USER_BADGES      → earned badges
//   Aggregated stats → loan/funding activity counts

import 'badge_model.dart';
import 'credit_profile_model.dart';
import 'profile_stats_model.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.reputationScore,
    required this.memberSince,
    required this.creditProfile,
    required this.stats,
    required this.badges,
    this.location,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String fullName;
  final int reputationScore;
  final DateTime memberSince;
  final String? location;
  final String? avatarUrl;

  final CreditProfileModel creditProfile;
  final ProfileStatsModel stats;
  final List<BadgeModel> badges;

  // Computed display properties 

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (email.isNotEmpty) {
      final local = email.split('@').first;
      if (local.isNotEmpty) {
        return '${local[0].toUpperCase()}${local.substring(1)}';
      }
    }
    return 'Member';
  }

  String get subtitleLine =>
      '$email · Member since ${_memberSinceLabel(memberSince)}';

  String get resolvedAvatarUrl =>
      avatarUrl ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$userId';

  static String _memberSinceLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}