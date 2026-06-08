import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_routes.dart';
import '../../../data/providers/data_providers.dart';
import 'email_verification_screen.dart' show _OnboardingStepIndicator;

/// Step 2 of onboarding: connect a bank account via Stitch.
///
/// In production this would open the Stitch Link OAuth URL in a WebView.
/// For now it simulates the OAuth flow with a mock connection dialog.
class BankConnectScreen extends ConsumerStatefulWidget {
  const BankConnectScreen({super.key});

  @override
  ConsumerState<BankConnectScreen> createState() => _BankConnectScreenState();
}

class _BankConnectScreenState extends ConsumerState<BankConnectScreen> {
  bool _connecting = false;

  static const _banks = [
    _BankOption(name: 'First National Bank', code: 'FNB', logo: '🏦'),
    _BankOption(name: 'Standard Bank', code: 'StandardBank', logo: '🏛️'),
    _BankOption(name: 'Stanbic Bank', code: 'Stanbic', logo: '🏢'),
    _BankOption(name: 'Absa Botswana', code: 'Absa', logo: '🏧'),
    _BankOption(name: 'Orange Money', code: 'OrangeMoney', logo: '📱'),
    _BankOption(name: 'Mascom MyZaka', code: 'Mascom', logo: '📲'),
  ];

  Future<void> _connectBank(_BankOption bank) async {
    setState(() => _connecting = true);

    // In production: launch Stitch OAuth URL, receive callback with code,
    // exchange code for tokens, then call createConnection.
    // Here we simulate with a 1.5s delay.
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final controller = ref.read(onboardingControllerProvider.notifier);
    final success = await controller.completeBankConnect(
      provider: 'stitch',
      bankName: bank.name,
      accountId: 'mock-${bank.code}-${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!mounted) return;
    setState(() => _connecting = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.kycUpload);
    } else {
      final state = ref.read(onboardingControllerProvider);
      final msg = state.asError?.error.toString().replaceFirst('Exception: ', '') ??
          'Failed to connect bank. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OnboardingStepIndicator(currentStep: 1),
              const SizedBox(height: 40),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
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
                'We use Stitch, a secure open banking provider, to read your transaction history. '
                'Your credentials are never stored by PulaPay.',
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 28),

              // Security badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Color(0xFF059669)),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _banks.length,
                  itemBuilder: (context, i) {
                    final bank = _banks[i];
                    return _connecting
                        ? _BankTile(bank: bank, onTap: null)
                        : _BankTile(
                            bank: bank,
                            onTap: () => _connectBank(bank),
                          );
                  },
                ),
              ),

              const SizedBox(height: 16),

              if (_connecting)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF059669)),
                      SizedBox(height: 8),
                      Text(
                        'Connecting securely…',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),

              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.kycUpload),
                child: const Text('Skip for now', style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankOption {
  final String name;
  final String code;
  final String logo;

  const _BankOption({required this.name, required this.code, required this.logo});
}

class _BankTile extends StatelessWidget {
  const _BankTile({required this.bank, required this.onTap});

  final _BankOption bank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(bank.logo, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bank.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
