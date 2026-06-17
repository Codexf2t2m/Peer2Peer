// Maps to the TRANSACTIONS table — all types visible in the wallet history.
// The TRANSACTIONS table covers: top_up, transfer, funding, repayment, fee.
//
// ERD columns used:
//   id, user_id, loan_request_id, active_loan_id,
//   type, gross_amount, fee_amount, net_amount, status, created_at

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// All transaction types that can appear in the wallet history.
enum WalletTransactionType {
  topUp,
  transfer,
  funding,
  repayment,
  fee,
  unknown;

  static WalletTransactionType fromString(String value) {
    return switch (value) {
      'top_up' => WalletTransactionType.topUp,
      'transfer' => WalletTransactionType.transfer,
      'funding' => WalletTransactionType.funding,
      'repayment' => WalletTransactionType.repayment,
      'fee' => WalletTransactionType.fee,
      _ => WalletTransactionType.unknown,
    };
  }
}

/// Immutable record of a single wallet transaction.
class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.grossAmount,
    required this.feeAmount,
    required this.netAmount,
    required this.status,
    required this.createdAt,
    this.loanRequestId,
    this.activeLoanId,
    this.counterpartyName,
    this.loanPurpose,
  });

  final String id;
  final String userId;
  final WalletTransactionType type;
  final double grossAmount;
  final double feeAmount;
  final double netAmount;

  /// 'pending' | 'completed' | 'failed'
  final String status;

  final DateTime createdAt;

  // Joined / enriched fields
  final String? loanRequestId;
  final String? activeLoanId;
  final String? counterpartyName;
  final String? loanPurpose;

  // Computed presentational properties 

  /// Credit transactions increase the user's balance.
  bool get isCredit =>
      type == WalletTransactionType.topUp ||
      type == WalletTransactionType.repayment;

  /// Human-readable title for the transaction tile.
  String get title {
    return switch (type) {
      WalletTransactionType.topUp => 'Wallet top-up',
      WalletTransactionType.transfer => 'Transfer',
      WalletTransactionType.funding =>
        loanPurpose?.isNotEmpty == true ? loanPurpose! : 'Loan funded',
      WalletTransactionType.repayment => 'Repayment received',
      WalletTransactionType.fee => 'Platform fee',
      WalletTransactionType.unknown => 'Transaction',
    };
  }

  /// Secondary detail line shown under the title.
  String get subtitle {
    if (counterpartyName != null && counterpartyName!.isNotEmpty) {
      return counterpartyName!;
    }
    return switch (type) {
      WalletTransactionType.topUp => 'Added to wallet',
      WalletTransactionType.transfer => 'Sent',
      WalletTransactionType.funding => 'Loan disbursed',
      WalletTransactionType.repayment => 'From borrower',
      WalletTransactionType.fee => 'Deducted',
      WalletTransactionType.unknown => '',
    };
  }

  /// Icon representing this transaction type.
  /// Changed return type from IconData to dynamic to handle HugeIcons' structural data types cleanly.
  dynamic get icon {
    return switch (type) {
      WalletTransactionType.topUp =>
        HugeIcons.strokeRoundedWalletAdd02,
      WalletTransactionType.transfer =>
        HugeIcons.strokeRoundedArrowLeftRight,
      WalletTransactionType.funding =>
        HugeIcons.strokeRoundedMoneySend02,
      WalletTransactionType.repayment =>
        HugeIcons.strokeRoundedMoneyReceive02,
      WalletTransactionType.fee =>
        HugeIcons.strokeRoundedReceiptText,
      WalletTransactionType.unknown =>
        HugeIcons.strokeRoundedReceiptText,
    };
  }

  // Serialisation 

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final loanRequest =
        json['loan_requests'] as Map<String, dynamic>?;
    final profile =
        loanRequest?['profiles'] as Map<String, dynamic>?;

    return WalletTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: WalletTransactionType.fromString(
          json['type'] as String? ?? ''),
      grossAmount: (json['gross_amount'] as num).toDouble(),
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
      loanRequestId: json['loan_request_id'] as String?,
      activeLoanId: json['active_loan_id'] as String?,
      loanPurpose: loanRequest?['purpose'] as String?,
      counterpartyName: profile?['full_name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}