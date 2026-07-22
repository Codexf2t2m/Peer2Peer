
// UC: View Borrower Profile + Fund Community Loan + Share Badge
//
// Architecture
// ────────────
// • ConsumerWidget — zero local state.
// • Takes [loanRequestId] as a route argument and passes it to the
//   family provider: communityFundViewModelProvider(loanRequestId).
// • Watches one AsyncValue<CommunityFundUiState> — profile + balance.
// • FundDialog is a separate ConsumerStatefulWidget; its loading state
//   never causes this screen to rebuild.
// • No DemoStore, no communityMembersProvider, no walletBalanceProvider
//   imported directly.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/widgets/app_back_button.dart';
import '../view_models/community_fund_view_model.dart';
import 'borrower_badges_section.dart';
import 'borrower_profile_header.dart';
import 'borrower_request_card.dart';
import 'fund_dialog.dart';

class CommunityFundScreen extends ConsumerWidget {
  const CommunityFundScreen({
    super.key,
    required this.loanRequestId,
  });

  final String loanRequestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState =
        ref.watch(communityFundViewModelProvider(loanRequestId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const AppBackButton()
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(communityFundViewModelProvider(loanRequestId)
                  .notifier)
              .refresh(),
          child: uiState.when(
            // Loading 
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

            // Error 
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.toString().replaceFirst(
                              'Exception: ', ''),
                          style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(communityFundViewModelProvider(
                                    loanRequestId)
                                .notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Data 
            data: (state) {
              final profile = state.profile;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    // Profile header 
                    BorrowerProfileHeader(
                      profile: profile,
                      walletBalance: state.walletBalance,
                    ),

                    const SizedBox(height: 32),

                    // About 
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
                        profile.about,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Badges 
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BorrowerBadgesSection(
                        badges: profile.badges,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Current request 
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
                    BorrowerRequestCard(profile: profile),

                    const SizedBox(height: 32),

                    // Fund button 
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0038FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed: profile.isFullyFunded
                            ? null
                            : () async {
                                final success =
                                    await FundDialog.show(
                                  context,
                                  profile: profile,
                                  walletBalance:
                                      state.walletBalance,
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Successfully funded '
                                        '${profile.borrowerName}.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          profile.isFullyFunded
                              ? 'Fully Funded'
                              : 'Fund Borrower',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}