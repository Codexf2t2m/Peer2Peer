import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/providers/session_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../ui/widgets/app_back_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final creditProfileAsync = ref.watch(creditProfileProvider);
    final badgesAsync = ref.watch(userBadgesProvider);

    final email = session.currentEmail;
    final displayName = formatDisplayName(email);
    final subtitle = email == null || email.isEmpty
        ? 'Member since Feb 2026 • Gaborone'
        : '$email • Member since Feb 2026';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileStatsProvider);
            ref.invalidate(creditProfileProvider);
            ref.invalidate(userBadgesProvider);
            await ref.read(profileStatsProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User info section
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Verified'),
                    const SizedBox(width: 8),
                    _buildChip('4 Cards Connected'),
                  ],
                ),
                const SizedBox(height: 32),

                // Credit Score and Risk assessment section
                creditProfileAsync.when(
                  data: (credit) {
                    final score = credit?.creditScore ?? 690;
                    final scorePercent = score / 1000.0;
                    final riskBand = credit?.riskBand ?? 'Fair';

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 84,
                              height: 84,
                              child: CircularProgressIndicator(
                                value: scorePercent,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                color: const Color(0xFF0038FF), // Bright blue
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${(scorePercent * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$riskBand — Top 15% of PulaPay users',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C2C2C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                  error: (err, _) => Text('Error loading credit: $err'),
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Grid
                statsAsync.when(
                  data: (stats) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _buildStatCard(
                          '${stats['total_requested'] ?? 0}',
                          'Loans requested',
                        ),
                        _buildStatCard(
                          '${stats['fully_repaid'] ?? 0}',
                          'Fully repaid',
                        ),
                        _buildStatCard(
                          '${stats['people_funded'] ?? 0}',
                          'People funded',
                        ),
                        _buildStatCard(
                          '${stats['late_payments'] ?? 0}',
                          'Late payments',
                        ),
                      ],
                    );
                  },
                  error: (err, _) => Text('Error loading stats: $err'),
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(height: 32),

                // Achievements Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                badgesAsync.when(
                  data: (userBadges) {
                    if (userBadges.isEmpty) {
                      // Fallback static achievements for new / demo users
                      return Row(
                        children: [
                          Expanded(
                            child: _buildAchievementBadge(
                              context,
                              'Verified\nMember',
                              0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAchievementBadge(
                              context,
                              'Trusted\nBorrower',
                              1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAchievementBadge(
                              context,
                              'Top\nRepayer',
                              2,
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: userBadges.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final badge = userBadges[index].badge;
                          return Container(
                            width: 110,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.workspace_premium, color: Color(0xFF0038FF), size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  badge.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (err, _) => Text('Error loading badges: $err'),
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(height: 32),

                // Borrowing Limit
                creditProfileAsync.when(
                  data: (credit) {
                    final limit = credit?.approvedBorrowingLimit ?? 2330.0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Borrowing Limit',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Next review',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'June 1, 2026',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF0038FF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatPula(limit),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Income bracket: P1,000–P5,000/mo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (err, _) => Text('Error loading limit: $err'),
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

                const SizedBox(height: 32),

                // Sign out button
                TextButton(
                  onPressed: () async {
                    await ref.read(sessionProvider.notifier).signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, String title, int index) {
    final colors = [
      const Color(0xFF0038FF), // Verified
      const Color(0xFF00BFA5), // Trusted
      const Color(0xFFFF8F00), // Top Repayer
    ];

    final icons = [
      HugeIcons.strokeRoundedShieldCheck,
      HugeIcons.strokeRoundedHandShake,
      HugeIcons.strokeRoundedAward02,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: colors[index].withValues(alpha: 0.1),
            child: HugeIcon(
              icon: icons[index],
              color: colors[index],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}
