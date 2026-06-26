// lib/ui/loans/widgets/active_loan_card.dart

import 'package:flutter/material.dart';

import '../../../data/models/active_loan_model.dart';
import '../../../shared/utils/formatters.dart';
import '../view_models/active_loans_viewmodel.dart';
import 'shared_widgets.dart';

/// Renders a single active loan card.
///
/// All business logic (color, label, progress) is sourced from the
/// top-level presentational helpers in [active_loans_view_model.dart].
/// This widget is a pure render tree with no logic of its own.
class ActiveLoanCard extends StatelessWidget {
  const ActiveLoanCard({
    super.key,
    required this.loan,
  });

  final ActiveLoanModel loan;

  @override
  Widget build(BuildContext context) {
    final isOverdue = loan.isOverdue;
    final daysLeft = loan.daysRemaining;
    final progress = loanRepaymentProgress(loan);
    final statusColor = loanStatusColor(loan);
    final statusLabel = loanStatusLabel(loan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isOverdue
            ? Border.all(color: const Color(0xFFEF4444), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: amount + status ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatPula(loan.principal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),

          const SizedBox(height: 4),

          // ── Repayment obligation ─────────────────────────────────────
          Text(
            'Repay ${formatPula(loan.totalRepaymentAmount)}',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B7280)),
          ),

          if (loan.loanPurpose != null) ...[
            const SizedBox(height: 2),
            Text(
              loan.loanPurpose!,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9CA3AF)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 14),

          // ── Progress bar ─────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 12),

          // ── Due date row ─────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: isOverdue
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                _dueDateLabel(isOverdue, daysLeft),
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(loan.dueDate),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _dueDateLabel(bool isOverdue, int daysLeft) {
    if (isOverdue) {
      final n = -daysLeft;
      return 'Overdue by $n day${n == 1 ? '' : 's'}';
    }
    if (daysLeft == 0) return 'Due today';
    return 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}';
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}