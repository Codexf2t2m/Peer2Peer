import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LoanPerformanceCard extends StatelessWidget {
  const LoanPerformanceCard({
    super.key,
    required this.ratePercent,
    required this.monthlyDelta,
  });

  final int ratePercent;
  final int monthlyDelta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Loan Performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                size: 14,
                color: Color(0xFF18A957),
              ),
              const SizedBox(width: 4),
              Text(
                'P$monthlyDelta this month',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF202223),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$ratePercent%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Repayment rate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}