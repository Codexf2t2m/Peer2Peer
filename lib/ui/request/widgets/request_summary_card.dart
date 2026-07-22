
// Live summary card showing the computed loan terms as the user types.
// Updates in real time from the form field values passed down by the screen.
// Pure render widget — no provider access.

import 'package:flutter/material.dart';

import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';

class RequestSummaryCard extends StatelessWidget {
  const RequestSummaryCard({
    super.key,
    required this.amount,
    required this.interestRate,
    required this.durationDays,
  });

  final double amount;
  final double interestRate;
  final int durationDays;

  double get _totalRepayment => amount * (1 + interestRate / 100);
  double get _interestAmount => _totalRepayment - amount;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan summary',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'You receive',
            value: formatPula(amount),
            bold: true,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Interest ($interestRate%)',
            value: formatPula(_interestAmount),
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total to repay',
            value: formatPula(_totalRepayment),
            bold: true,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Duration',
            value: '$durationDays day${durationDays == 1 ? '' : 's'}',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? style
                : style?.copyWith(color: const Color(0xFF6B7280))),
        Text(value, style: style),
      ],
    );
  }
}