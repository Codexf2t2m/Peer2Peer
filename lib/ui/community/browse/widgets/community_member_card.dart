
// UC: Browse Community Feed + Fund Community Loan + View Borrower Profile
//
// Renders a single borrower card in the community feed.
// Extracted from the screen's _buildFeedCard() private method.
// Pure render widget — receives a typed model and route callbacks.

import 'package:flutter/material.dart';

import '../../../../data/models/community_member_model.dart';
import '../../../../../shared/utils/formatters.dart';

class CommunityMemberCard extends StatelessWidget {
  const CommunityMemberCard({
    super.key,
    required this.member,
    required this.onFund,
    required this.onViewProfile,
  });

  final CommunityMemberModel member;
  final VoidCallback onFund;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + score 
          Row(
            children: [
              _BorrowerAvatar(avatarUrl: member.avatarUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.borrowerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreDisplay(
                score: member.score,
                color: member.scoreColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Purpose / description 
          Text(
            member.requestDescription,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF1E1E1E),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          // Loan stats panel 
          _LoanStatsPanel(member: member),

          const SizedBox(height: 20),

          // Action buttons 
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0038FF),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onFund,
                  child: Text(
                    member.fundButtonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E1E1E),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: Colors.grey.shade300, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onViewProfile,
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sub-widgets 

class _BorrowerAvatar extends StatelessWidget {
  const _BorrowerAvatar({required this.avatarUrl});
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: Colors.grey.shade200,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Score',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _LoanStatsPanel extends StatelessWidget {
  const _LoanStatsPanel({required this.member});
  final CommunityMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: member.progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white,
                  color: const Color(0xFF0038FF),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  member.progressText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Stats column
          Expanded(
            child: Column(
              children: [
                _StatRow(
                    label: 'Amount',
                    value: formatPula(member.amountRequested)),
                const SizedBox(height: 8),
                _StatRow(
                    label: 'Return',
                    value: formatPula(member.expectedReturn)),
                const SizedBox(height: 8),
                _StatRow(
                    label: 'Due in', value: member.dueIn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}