
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/wallet_command_view_model.dart';
import '../../../../shared/utils/formatters.dart';

class TopUpDialog extends ConsumerStatefulWidget {
  const TopUpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TopUpDialog(),
    );
  }

  @override
  ConsumerState<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends ConsumerState<TopUpDialog> {
  final _controller = TextEditingController(text: '200');

  @override
  void dispose() {
    _controller.dispose();
    // Reset command state when dialog closes so stale errors don't linger.
    ref.read(walletCommandViewModelProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandState = ref.watch(walletCommandViewModelProvider);
    final isLoading = commandState.isLoading;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Top up wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
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
          onPressed:
              isLoading ? null : () => Navigator.of(context).pop(),
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
              : const Text('Add funds'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final amount =
        double.tryParse(_controller.text.trim()) ?? 0;
    final success = await ref
        .read(walletCommandViewModelProvider.notifier)
        .topUp(amount);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully topped up ${formatPula(amount)}.'),
        ),
      );
    }
  }
}