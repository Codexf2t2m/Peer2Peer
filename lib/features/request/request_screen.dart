import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/data_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../ui/widgets/app_back_button.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _amountCtrl = TextEditingController(text: '500');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid request amount.')),
      );
      return;
    }

    final success = await ref.read(loanRequestControllerProvider.notifier).submitRequest(
          amount: amount,
          interestRate: 15.0, // Sensible default interest rate
          durationDays: 30, // Sensible default duration
          purpose: _noteCtrl.text.trim().isEmpty ? 'Community loan request' : _noteCtrl.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully for P$amount.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(loanRequestControllerProvider);
    final isSending = requestState.isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
        titleSpacing: 16,
        title: Text('Request', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountCtrl,
                    enabled: !isSending,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: 'P',
                      hintText: '0',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Note (optional)', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteCtrl,
                    enabled: !isSending,
                    decoration: const InputDecoration(hintText: 'What is this for?'),
                  ),
                  if (requestState.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${requestState.error}',
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isSending ? null : _submit,
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send request'),
            ),
          ],
        ),
      ),
    );
  }
}
