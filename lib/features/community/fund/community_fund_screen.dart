import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app_routes.dart';
import '../../../app_state.dart';
import '../../../data/providers/data_providers.dart';
import '../../../ui/widgets/app_back_button.dart';

class CommunityFundScreen extends ConsumerWidget {
  const CommunityFundScreen({super.key, this.memberId});

  final String? memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(communityMembersProvider);
    final walletBalanceAsync = ref.watch(walletBalanceProvider);

    final member = membersAsync.valueOrNull?.firstWhere(
      (m) => m.id == memberId,
      orElse: () => membersAsync.valueOrNull?.first ?? DemoStore.instance.memberById(memberId),
    ) ?? DemoStore.instance.memberById(memberId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(communityMembersProvider);
            ref.invalidate(walletBalanceProvider);
            await ref.read(communityMembersProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(member.avatarUrl),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'Rep Score ${member.score} • ${member.scoreLabel}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your wallet balance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      Text(
                        walletBalanceAsync.maybeWhen(
                          data: (balance) => formatPula(balance),
                          orElse: () => 'P0',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0038FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    member.about,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verified badges',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildAchievementBadge(context, 'Verified\nMember', 0),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(context, 'Trusted\nBorrower', 1),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(context, 'Clean\nRecord', 3),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(context, 'Top\nRepayer', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current request',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: member.progress,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFFF0F2F5),
                              color: const Color(0xFF0038FF),
                            ),
                            Text(
                              member.progressText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatRow('Target amount', formatPula(member.targetAmount)),
                            const SizedBox(height: 10),
                            _buildStatRow('Interest rate', '${(member.returnAmount / member.targetAmount * 100 - 100).round()}%'),
                            const SizedBox(height: 10),
                            _buildStatRow('Due in', member.dueIn),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0038FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: member.remainingAmount <= 0
                        ? null
                        : () => _openFundDialog(context, ref, member),
                    child: Text(
                      member.remainingAmount <= 0 ? 'Fully Funded' : 'Fund Borrower',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFundDialog(BuildContext context, WidgetRef ref, CommunityMember member) {
    final controller = TextEditingController();
    final rootContext = context;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final fundingState = ref.watch(fundingControllerProvider);
            final walletBalance = ref.watch(walletBalanceProvider).valueOrNull ?? 0.0;
            final isFundingLoading = fundingState.isLoading;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Fund ${member.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter funding amount. You have ${formatPula(walletBalance)} available in your wallet.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    enabled: !isFundingLoading,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'P',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (fundingState.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${fundingState.error}',
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isFundingLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isFundingLoading
                      ? null
                      : () async {
                          final amount = double.tryParse(controller.text.trim()) ?? 0;
                          final success = await ref
                              .read(fundingControllerProvider.notifier)
                              .fundLoan(loanRequestId: member.id, amount: amount);

                          if (success) {
                            if (context.mounted) Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              SnackBar(content: Text('Successfully funded ${member.name} with P$amount.')),
                            );
                          }
                        },
                  child: isFundingLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(BuildContext context, String label, int type) {
    final isLocked = type == 2;

    late final Widget iconWidget;
    switch (type) {
      case 0:
        iconWidget = Container(
          width: 44,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFbf8957), Color(0xFF81522a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedStar,
            color: Colors.white,
            size: 28,
          ),
        );
        break;
      case 1:
        iconWidget = Transform.rotate(
          angle: 3.14159 / 4,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: -3.14159 / 4,
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedStarOff,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
        break;
      case 3:
        iconWidget = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedStar,
            color: Colors.white,
            size: 24,
          ),
        );
        break;
      case 2:
      default:
        iconWidget = SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: 0.6,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF0038FF),
                  strokeCap: StrokeCap.round,
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedLock,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        );
        break;
    }

    final content = Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 48, child: Center(child: iconWidget)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: isLocked ? Colors.grey.shade400 : const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );

    if (isLocked) {
      return CustomPaint(
        painter: DashedRRectPainter(
          color: Colors.grey.shade300,
          strokeWidth: 1.2,
          radius: 20.0,
          dashWidth: 4.0,
          dashSpace: 4.0,
        ),
        child: content,
      );
    }

    return content;
  }
}

class DashedRRectPainter extends CustomPainter {
  DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
