
// UC: Fund Community Loan — the funding amount dialog.
//
// Extracted from _openFundDialog() on the screen.
// Uses ConsumerStatefulWidget so its loading state is scoped
// to the dialog — the profile screen never rebuilds on dialog changes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/borrower_profile_model.dart';
import '../view_models/community_fund_view_model.dart';

class FundDialog extends ConsumerStatefulWidget {
  const FundDialog({
    super.key,
    required this.profile,
    required this.walletBalance,
  });

  final BorrowerProfileModel profile;
  final double walletBalance;

  static Future<bool> show(
    BuildContext context, {
    required BorrowerProfileModel profile,
    required double walletBalance,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FundDialog(
        profile: profile,
        walletBalance: walletBalance,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<FundDialog> createState() => _FundDialogState();
}

class _FundDialogState extends ConsumerState<FundDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    ref.read(communityFundCommandViewModelProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount =
        double.tryParse(_controller.text.trim()) ?? 0;
    final success = await ref
        .read(communityFundCommandViewModelProvider.notifier)
        .fund(
          loanRequestId: widget.profile.loanRequestId,
          amount: amount,
        );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commandState =
        ref.watch(communityFundCommandViewModelProvider);
    final isLoading = commandState.isLoading;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      title: Text('Fund ${widget.profile.borrowerName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter funding amount. You have '
            '${_formatPula(widget.walletBalance)} available.',
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'P ',
              border: OutlineInputBorder(),
            ),
          ),
          if (commandState.hasError) ...[
            const SizedBox(height: 8),
            Text(
              commandState.errorMessage ?? '',
              style: const TextStyle(
                  color: Color(0xFFDC2626), fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }

  static String _formatPula(double amount) =>
      'P ${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';
}