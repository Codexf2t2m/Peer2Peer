import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/active_loan_model.dart';
import '../../../data/providers/data_providers.dart';
import '../../../shared/utils/formatters.dart';
import '../../widgets/app_back_button.dart';

/// UC14 – View Active Loans
///
/// Shows all loans where the signed-in user is the borrower,
/// including principal, repayment amount, due date and status badge.
class ActiveLoansScreen extends ConsumerWidget {
  const ActiveLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeLoansProvider);
    final requestsAsync = ref.watch(myLoanRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: const Text(
          'My Loans',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeLoansProvider);
          ref.invalidate(myLoanRequestsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Active loans (borrower) ──────────────────────────────────
            _SectionHeader(title: 'Active Loans', icon: Icons.payments_outlined),
            const SizedBox(height: 12),
            activeAsync.when(
              data: (loans) {
                if (loans.isEmpty) {
                  return _EmptyCard(
                    icon: Icons.check_circle_outline,
                    message: 'No active loans — all clear!',
                  );
                }
                return Column(
                  children: loans
                      .map((l) => _ActiveLoanCard(loan: l))
                      .toList(),
                );
              },
              error: (e, _) => _ErrorCard(message: e.toString()),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Loan request history ─────────────────────────────────────
            _SectionHeader(
                title: 'Loan Request History', icon: Icons.history_rounded),
            const SizedBox(height: 12),
            requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return _EmptyCard(
                    icon: Icons.inbox_outlined,
                    message: "You haven't submitted any loan requests yet.",
                  );
                }
                return Column(
                  children: requests
                      .map((r) => _LoanRequestCard(request: r))
                      .toList(),
                );
              },
              error: (e, _) => _ErrorCard(message: e.toString()),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Active loan card ──────────────────────────────────────────────────────────

class _ActiveLoanCard extends StatelessWidget {
  const _ActiveLoanCard({required this.loan});

  final ActiveLoanModel loan;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final due = loan.dueDate;
    final isOverdue = due.isBefore(now) && loan.status == 'active';
    final daysLeft = due.difference(now).inDays;
    final progress = loan.principal > 0
        ? (loan.totalRepaymentAmount - loan.principal) / loan.totalRepaymentAmount
        : 0.0;

    final statusColor = switch (loan.status) {
      'active' => isOverdue ? const Color(0xFFEF4444) : const Color(0xFF059669),
      'completed' => const Color(0xFF6B7280),
      'default' => const Color(0xFFEF4444),
      _ => const Color(0xFF6B7280),
    };

    final statusLabel = isOverdue ? 'Overdue' : loan.status.toUpperCase();

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
              _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Repay ${formatPula(loan.totalRepaymentAmount)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor:
                  AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),
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
                isOverdue
                    ? 'Overdue by ${-daysLeft} day${daysLeft == -1 ? '' : 's'}'
                    : daysLeft == 0
                        ? 'Due today'
                        : 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}',
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
                'Due ${_formatDate(due)}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

// ── Loan request card ─────────────────────────────────────────────────────────

class _LoanRequestCard extends StatelessWidget {
  const _LoanRequestCard({required this.request});

  final dynamic request; // LoanRequestModel

  @override
  Widget build(BuildContext context) {
    final status = request.status as String? ?? 'unknown';
    final statusColor = switch (status) {
      'active' => const Color(0xFF0038FF),
      'funded' => const Color(0xFF059669),
      'repaying' => const Color(0xFF7C3AED),
      'completed' => const Color(0xFF6B7280),
      'cancelled' => const Color(0xFFEF4444),
      _ => const Color(0xFF9CA3AF),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long_outlined,
                color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPula(
                      (request.amountRequested as num?)?.toDouble() ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (request.purpose as String?) ?? 'No description',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _StatusBadge(label: status.toUpperCase(), color: statusColor),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF374151)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.replaceFirst('Exception: ', ''),
        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
      ),
    );
  }
}
