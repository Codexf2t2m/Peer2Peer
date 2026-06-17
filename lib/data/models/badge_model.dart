
// Maps to the BADGES and USER_BADGES tables from the ERD.
//
// BADGES:      code PK, name, description, requirement_description, icon_name
// USER_BADGES: id, user_id FK, badge_code FK, earned_at, is_featured
//
// The original screen hardcoded badge types as integers (0,1,2,3).
// This model gives badges a proper identity so the UI is data-driven.

/// The visual style / tier of a badge.
enum BadgeTier {
  bronze,   // Verified Member
  silver,   // Trusted Borrower
  gold,     // Top Repayer
  platinum, // Clean Record
}

/// A badge earned (or locked) by a user.
class BadgeModel {
  const BadgeModel({
    required this.code,
    required this.name,
    required this.description,
    required this.iconName,
    required this.tier,
    this.earnedAt,
    this.isFeatured = false,
    this.progressToUnlock,
  });

  final String code;
  final String name;
  final String description;
  final String iconName;
  final BadgeTier tier;

  /// Null when the badge has not yet been earned.
  final DateTime? earnedAt;

  final bool isFeatured;

  /// 0.0–1.0 progress toward earning this badge. Null when already earned.
  final double? progressToUnlock;

  bool get isEarned => earnedAt != null;
  bool get isLocked => !isEarned;

  // Serialisation 

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    final earnedAt = json['earned_at'] != null
        ? DateTime.parse(json['earned_at'] as String)
        : null;

    return BadgeModel(
      code: json['badge_code'] as String? ?? json['code'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'star',
      tier: BadgeTier.values.firstWhere(
        (t) => t.name == (json['tier'] as String? ?? 'bronze'),
        orElse: () => BadgeTier.bronze,
      ),
      earnedAt: earnedAt,
      isFeatured: json['is_featured'] as bool? ?? false,
      progressToUnlock:
          (json['progress_to_unlock'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}