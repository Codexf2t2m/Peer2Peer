
// Maps to the wallet-relevant columns on the PROFILES table.
// The wallet balance is the user's platform wallet (available_lending_amount),
// separate from their bank account balance.

/// Immutable snapshot of a user's platform wallet state.
class WalletModel {
  const WalletModel({
    required this.userId,
    required this.availableBalance,
    required this.borrowingLimit,
    required this.availableLendingAmount,
  });

  final String userId;

  /// The user's spendable platform wallet balance (BWP).
  final double availableBalance;

  /// The maximum amount this user is approved to borrow.
  final double borrowingLimit;

  /// The amount currently available for lending out.
  final double availableLendingAmount;

  // Computed 

  bool get hasBalance => availableBalance > 0;

  static const empty = WalletModel(
    userId: '',
    availableBalance: 0,
    borrowingLimit: 0,
    availableLendingAmount: 0,
  );

  // Serialisation 

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['id'] as String,
      availableBalance:
          (json['available_lending_amount'] as num?)?.toDouble() ?? 0,
      borrowingLimit:
          (json['borrowing_limit'] as num?)?.toDouble() ?? 0,
      availableLendingAmount:
          (json['available_lending_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  WalletModel copyWith({double? availableBalance}) {
    return WalletModel(
      userId: userId,
      availableBalance: availableBalance ?? this.availableBalance,
      borrowingLimit: borrowingLimit,
      availableLendingAmount: availableLendingAmount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          availableBalance == other.availableBalance;

  @override
  int get hashCode => Object.hash(userId, availableBalance);
}