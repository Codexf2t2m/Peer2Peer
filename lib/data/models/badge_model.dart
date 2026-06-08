class BadgeModel {
  const BadgeModel({
    required this.code,
    required this.name,
    this.description,
    this.requirementDescription,
    this.iconName,
  });

  final String code;
  final String name;
  final String? description;
  final String? requirementDescription;
  final String? iconName;

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      requirementDescription: json['requirement_description'] as String?,
      iconName: json['icon_name'] as String?,
    );
  }
}

class UserBadgeModel {
  const UserBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeCode,
    required this.earnedAt,
    required this.isFeatured,
    this.badge,
  });

  final String id;
  final String userId;
  final String badgeCode;
  final DateTime earnedAt;
  final bool isFeatured;

  /// Populated when fetched with a join on `badges`.
  final BadgeModel? badge;

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    final badgeJson = json['badges'] as Map<String, dynamic>?;
    return UserBadgeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeCode: json['badge_code'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
      badge: badgeJson != null ? BadgeModel.fromJson(badgeJson) : null,
    );
  }
}
