
// UC: Connect Bank Account — Step 2 of onboarding.
//
// Architecture
// • ConsumerWidget — zero local state.
// • ref.listen handles navigation on BankConnectSuccess and shows
//   a snackbar on BankConnectError.
// • Grid disables itself while any connection is in flight via
//   uiState.isLoading.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app_routes.dart';
import '../../widgets/onboarding_step_indicator.dart';
import '../view_models/bank_connect_view_model.dart';
import 'bank_tile.dart';

class BankConnectScreen extends ConsumerWidget {
  const BankConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(bankConnectViewModelProvider, (_, next) {
      if (next is BankConnectSuccess) {
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.kycUpload);
      } else if (next is BankConnectError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    });

    final uiState = ref.watch(bankConnectViewModelProvider);
    final isLoading = uiState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 1),
              const SizedBox(height: 40),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669)
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: Color(0xFF059669),
                  size: 36,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Connect your bank',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We use Stitch, a secure open banking provider, '
                'to read your transaction history. Your credentials '
                'are never stored by PulaPay.',
                style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.5),
              ),
              const SizedBox(height: 28),

              // Security badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 16,
                        color: Color(0xFF059669)),
                    SizedBox(width: 8),
                    Text(
                      'Bank-grade 256-bit encryption via Stitch',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Select your bank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: bankOptions.length,
                  itemBuilder: (context, i) {
                    final bank = bankOptions[i];
                    return BankTile(
                      bank: bank,
                      onTap: isLoading
                          ? null
                          : () => ref
                              .read(
                                  bankConnectViewModelProvider
                                      .notifier)
                              .connect(bank),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              if (isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                          color: Color(0xFF059669)),
                      const SizedBox(height: 8),
                      Text(
                        uiState is BankConnectLoading
                            ? 'Connecting to ${uiState.bankName}…'
                            : 'Connecting securely…',
                        style: const TextStyle(
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),

              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(
                        AppRoutes.kycUpload),
                child: const Text('Skip for now',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}