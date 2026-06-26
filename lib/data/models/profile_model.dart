class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.location,
    this.lendingMode,
    this.availableLendingAmount = 0,
    this.borrowingLimit = 0,
    this.reputationScore = 'NEW',
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? location;
  final String? lendingMode;
  final double availableLendingAmount;
  final double borrowingLimit;
  final String reputationScore;
  final DateTime createdAt;

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!.trim();
    final name = email.split('@').first.trim();
    if (name.isEmpty) return 'there';
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      lendingMode: json['lending_mode'] as String?,
      availableLendingAmount:
          (json['available_lending_amount'] as num?)?.toDouble() ?? 0,
      borrowingLimit: (json['borrowing_limit'] as num?)?.toDouble() ?? 0,
      reputationScore: json['reputation_score'] as String? ?? 'NEW',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'location': location,
        'lending_mode': lendingMode,
        'available_lending_amount': availableLendingAmount,
        'borrowing_limit': borrowingLimit,
        'reputation_score': reputationScore,
      };

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? location,
    String? lendingMode,
    double? availableLendingAmount,
    double? borrowingLimit,
    String? reputationScore,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      lendingMode: lendingMode ?? this.lendingMode,
      availableLendingAmount:
          availableLendingAmount ?? this.availableLendingAmount,
      borrowingLimit: borrowingLimit ?? this.borrowingLimit,
      reputationScore: reputationScore ?? this.reputationScore,
      createdAt: createdAt,
    );
  }
}
