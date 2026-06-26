// lib/ui/loans/widgets/loan_request_card.dart

import 'package:flutter/material.dart';

import '../../../data/models/loan_request_model.dart';
import '../../../shared/utils/formatters.dart';
import '../view_models/loan_requests_viewmodel.dart';
import 'shared_widgets.dart';

/// Renders a single loan request summary card.
///
/// Accepts a strongly-typed [LoanRequestModel] — no more [dynamic].
/// Status colour is resolved via the top-level [requestStatusColor] helper.
class LoanRequestCard extends StatelessWidget {
  const LoanRequestCard({
    super.key,
    required this.request,
  });

  final LoanRequestModel request;

  @override
  Widget build(BuildContext context) {
    final statusColor = requestStatusColor(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon container ─────────────────────────────────────────
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

          // ── Amount + purpose ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPula(request.amountRequested),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.purpose ?? 'No description',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          StatusBadge(
            label: request.status.toUpperCase(),
            color: statusColor,
          ),
        ],
      ),
    );
  }
}